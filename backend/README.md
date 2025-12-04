# MOTORPARTS Backend (FastAPI)

This small backend provides a rate-limited `/login` endpoint that issues JWT access tokens.

Quick start (PowerShell):

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env
# Edit .env to set JWT_SECRET
uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```

Endpoints:
- `POST /login` — accepts JSON `{ "email": "...", "password": "..." }`. Returns `{ "access_token": "...", "token_type": "bearer" }` on success.

Rate limiting:
- The `/login` endpoint is rate-limited by IP (default 5 requests per minute). Adjust limits in `app.py`.

Supabase proxy notes:
- This backend can optionally proxy authentication to Supabase instead of using the local SQLite user store. To enable proxying, set `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` in your `.env` (see `.env.example`).
- When proxied, the backend forwards credentials to Supabase Auth and returns Supabase's session response (including `access_token` and `refresh_token`). The backend still enforces rate-limits and can add additional business logic.

Integration with Flutter:
- Update your login call in `lib/services/auth_service.dart` to POST to `http://<backend-host>:8000/login` instead of directly to Supabase, then store tokens securely (see note below).
- Use `flutter_secure_storage` to store `access_token` and `refresh_token` on-device. Do not store refresh tokens in plain SharedPreferences.

Docker / sharing (easy way to give this backend to someone)
- Build & run with Docker (recommended so your friend doesn't need Python env setup):

```powershell
cd backend
# Build image (runs pip install inside image)
docker build -t motorparts-backend:latest .

# Run container (reads .env from backend/.env)
docker run --env-file .env -p 8000:8000 --name motorparts_backend motorparts-backend:latest
```

- Or use `docker compose` (reads `.env` by default via `env_file`):

```powershell
cd backend
docker compose up --build
```

- After starting, the backend is reachable at `http://localhost:8000` (or `http://<host-ip>:8000`). Update `SupabaseConfig.backendUrl` in the Flutter app accordingly (on Android emulator use `http://10.0.2.2:8000`).

Sharing notes:
- To share easily, give your friend the `backend/` folder (zip or push to a repo) plus the `.env` values (do not send the service role key over insecure channels). They can run the above `docker` commands.
- Alternatively, build the Docker image and push it to a private registry (Docker Hub, GitHub Container Registry) and have your friend `docker pull` it.

Security reminder:
- Never commit `.env` with secrets to a public repo. Share `.env` values via a secure channel.

Security notes:
- For production, use HTTPS, a strong `JWT_SECRET`, and a persistent user store (this example uses SQLite). Consider integrating with your existing Supabase user data instead of a separate DB.
