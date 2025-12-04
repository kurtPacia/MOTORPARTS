import os
import sqlite3
import requests
from datetime import datetime, timedelta
from dotenv import load_dotenv

from fastapi import FastAPI, Request, HTTPException
from pydantic import BaseModel
from passlib.context import CryptContext
import jwt
from slowapi import Limiter
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address
from slowapi.middleware import SlowAPIMiddleware
from slowapi import _rate_limit_exceeded_handler

# Configuration
load_dotenv()
JWT_SECRET = os.getenv("JWT_SECRET", "change_me")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "60"))
DB_PATH = os.getenv("DATABASE_URL", "sqlite:///./users.db").replace("sqlite:///./", "")

# Lockout policy for repeated failed logins (per-email, stored in SQLite)
MAX_FAILED_ATTEMPTS = int(os.getenv("MAX_FAILED_ATTEMPTS", "5"))
LOCKOUT_SECONDS = int(os.getenv("LOCKOUT_SECONDS", "180"))  # default 3 minutes

# Supabase proxy configuration (optional). If set, the backend will forward
# login requests to Supabase Auth and return Supabase's response. Requires
# `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` to be set in the environment.
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

limiter = Limiter(key_func=get_remote_address)
app = FastAPI()
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(SlowAPIMiddleware)

class LoginIn(BaseModel):
    email: str
    password: str


def get_db_conn():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def initialize_db():
    conn = get_db_conn()
    cur = conn.cursor()
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL
        )
        """
    )
    # Table to track failed login attempts and temporary lockouts (per email)
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS login_attempts (
            email TEXT PRIMARY KEY,
            attempts INTEGER NOT NULL DEFAULT 0,
            last_attempt TEXT,
            locked_until TEXT
        )
        """
    )
    cur.execute("SELECT COUNT(*) AS c FROM users")
    row = cur.fetchone()
    if row is None or row[0] == 0:
        # Create a default test user. Change in production.
        test_hash = pwd_context.hash("password123")
        try:
            cur.execute("INSERT INTO users (email, password_hash) VALUES (?, ?)", ("test@example.com", test_hash))
            conn.commit()
        except Exception:
            pass
    conn.close()


def _get_attempt_row(email: str):
    conn = get_db_conn()
    cur = conn.cursor()
    cur.execute("SELECT attempts, last_attempt, locked_until FROM login_attempts WHERE email = ?", (email,))
    row = cur.fetchone()
    conn.close()
    return row


def is_locked(email: str):
    row = _get_attempt_row(email)
    if not row:
        return False, 0
    locked_until = row["locked_until"]
    if not locked_until:
        return False, 0
    try:
        locked_dt = datetime.fromisoformat(locked_until)
    except Exception:
        return False, 0
    now = datetime.utcnow()
    if now < locked_dt:
        return True, int((locked_dt - now).total_seconds())
    return False, 0


def record_failed_attempt(email: str):
    now = datetime.utcnow()
    row = _get_attempt_row(email)
    conn = get_db_conn()
    cur = conn.cursor()
    if not row:
        cur.execute("INSERT INTO login_attempts (email, attempts, last_attempt) VALUES (?, ?, ?)", (email, 1, now.isoformat()))
    else:
        attempts = row["attempts"] + 1
        if attempts >= MAX_FAILED_ATTEMPTS:
            # set lockout window and reset attempts
            locked_until = (now + timedelta(seconds=LOCKOUT_SECONDS)).isoformat()
            cur.execute("REPLACE INTO login_attempts (email, attempts, last_attempt, locked_until) VALUES (?, ?, ?, ?)", (email, 0, now.isoformat(), locked_until))
        else:
            cur.execute("REPLACE INTO login_attempts (email, attempts, last_attempt, locked_until) VALUES (?, ?, ?, NULL)", (email, attempts, now.isoformat()))
    conn.commit()
    conn.close()


def reset_attempts(email: str):
    conn = get_db_conn()
    cur = conn.cursor()
    cur.execute("DELETE FROM login_attempts WHERE email = ?", (email,))
    conn.commit()
    conn.close()


@app.on_event("startup")
def startup_event():
    initialize_db()


@app.post("/login")
@limiter.limit("5/minute")
async def login(payload: LoginIn, request: Request):
    # If Supabase proxy is configured, forward the credentials to Supabase
    # Auth endpoint and return its response. This keeps user management
    # centralized in Supabase while allowing this backend to enforce
    # rate-limits and additional business logic.
    # Check per-email lockout before attempting auth (works for both Supabase proxy and local auth)
    locked, remaining = is_locked(payload.email)
    if locked:
        raise HTTPException(status_code=429, detail=f"Too many failed attempts. Try again in {remaining} seconds")

    if SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY:
        target = f"{SUPABASE_URL.rstrip('/')}/auth/v1/token?grant_type=password"
        headers = {
            "apikey": SUPABASE_SERVICE_ROLE_KEY,
            "Authorization": f"Bearer {SUPABASE_SERVICE_ROLE_KEY}",
            "Content-Type": "application/json",
        }
        try:
            resp = requests.post(target, headers=headers, json={"email": payload.email, "password": payload.password}, timeout=10)
        except requests.RequestException:
            raise HTTPException(status_code=502, detail="Auth proxy error")

        if resp.status_code != 200:
            # record failed attempt for this email
            try:
                record_failed_attempt(payload.email)
            except Exception:
                pass
            # forward Supabase error message when available, but avoid leaking internals
            detail = resp.json().get("error_description") or resp.json().get("error") or "Invalid credentials"
            raise HTTPException(status_code=401, detail=detail)

        # Successful: clear attempt counter and return Supabase's session JSON
        try:
            reset_attempts(payload.email)
        except Exception:
            pass
        return resp.json()

    # Fallback: local SQLite-based auth (useful for testing without Supabase)
    conn = get_db_conn()
    cur = conn.cursor()
    cur.execute("SELECT * FROM users WHERE email = ?", (payload.email,))
    row = cur.fetchone()
    conn.close()

    if not row:
        # Do not reveal whether the user exists; record failed attempt and return generic error
        try:
            record_failed_attempt(payload.email)
        except Exception:
            pass
        raise HTTPException(status_code=401, detail="Invalid credentials")

    password_hash = row["password_hash"]
    if not pwd_context.verify(payload.password, password_hash):
        # Wrong password: record failed attempt and inform user generally
        try:
            record_failed_attempt(payload.email)
        except Exception:
            pass
        # Optionally provide remaining time if the action triggered a lockout
        locked, remaining = is_locked(payload.email)
        if locked:
            raise HTTPException(status_code=429, detail=f"Too many failed attempts. Try again in {remaining} seconds")
        raise HTTPException(status_code=401, detail="Invalid credentials")

    expires = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    token = jwt.encode({"sub": payload.email, "exp": expires}, JWT_SECRET, algorithm="HS256")

    # Successful login: reset failed-attempt tracking
    try:
        reset_attempts(payload.email)
    except Exception:
        pass

    return {"access_token": token, "token_type": "bearer"}


@app.get("/health")
async def health():
    return {"status": "ok"}


class RefreshIn(BaseModel):
    refresh_token: str


@app.post("/refresh")
@limiter.limit("10/minute")
async def refresh_token_endpoint(payload: RefreshIn, request: Request):
    """Refresh access token by proxying to Supabase (server-side).

    Expects JSON: { "refresh_token": "..." }
    Returns Supabase token response on success.
    """
    if not (SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY):
        raise HTTPException(status_code=400, detail="Refresh not configured on server")

    target = f"{SUPABASE_URL.rstrip('/')}/auth/v1/token?grant_type=refresh_token"
    headers = {
        "apikey": SUPABASE_SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_ROLE_KEY}",
        "Content-Type": "application/json",
    }

    try:
        resp = requests.post(target, headers=headers, json={"refresh_token": payload.refresh_token}, timeout=10)
    except requests.RequestException:
        raise HTTPException(status_code=502, detail="Auth proxy error")

    if resp.status_code != 200:
        detail = resp.json().get("error_description") or resp.json().get("error") or "Unable to refresh token"
        raise HTTPException(status_code=401, detail=detail)

    return resp.json()
