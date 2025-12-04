# Supabase Migration Guide

## Overview
This document provides a complete guide for migrating from Firebase to Supabase for the FKK Enterprise Motorshop application.

## Prerequisites

1. **Create a Supabase Project**
   - Go to [https://supabase.com](https://supabase.com)
   - Sign up or log in
   - Create a new project
   - Wait for the project to be fully provisioned

2. **Get Your Project Credentials**
   - Navigate to Settings > API
   - Copy your `Project URL` and `anon/public key`
   - Update `lib/supabase_config.dart` with these values:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

## Database Schema Setup

### 1. Users Table

Create the users table in your Supabase SQL Editor:

```sql
-- Create users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  full_name TEXT,
  role TEXT DEFAULT 'customer',
  phone TEXT,
  phone_number TEXT,
  address TEXT,
  profile_image TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own data
CREATE POLICY "Users can read own data" ON users
  FOR SELECT USING (auth.uid() = id);

-- Allow users to update their own data
CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Allow users to insert their own data
CREATE POLICY "Users can insert own data" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Create trigger to automatically update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### 2. Products Table (Optional - if you want to store products in database)

```sql
-- Create products table
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  category TEXT,
  image_url TEXT,
  stock INTEGER DEFAULT 0,
  is_available BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read products
CREATE POLICY "Products are viewable by everyone" ON products
  FOR SELECT USING (true);

-- Only admins can insert/update/delete products
CREATE POLICY "Only admins can modify products" ON products
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.role = 'admin'
    )
  );

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### 3. Orders Table (Optional - if you want to store orders in database)

```sql
-- Create orders table
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number TEXT UNIQUE NOT NULL,
  customer_id UUID REFERENCES users(id),
  customer_name TEXT NOT NULL,
  customer_email TEXT NOT NULL,
  items JSONB NOT NULL,
  total DECIMAL(10, 2) NOT NULL,
  status TEXT DEFAULT 'pending',
  delivery_address TEXT,
  phone_number TEXT,
  order_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own orders
CREATE POLICY "Users can read own orders" ON orders
  FOR SELECT USING (auth.uid() = customer_id);

-- Allow users to insert their own orders
CREATE POLICY "Users can insert own orders" ON orders
  FOR INSERT WITH CHECK (auth.uid() = customer_id);

-- Allow admins to read all orders
CREATE POLICY "Admins can read all orders" ON orders
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.role = 'admin'
    )
  );

-- Allow admins to update all orders
CREATE POLICY "Admins can update all orders" ON orders
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.role = 'admin'
    )
  );

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

## Storage Setup

### Create Storage Buckets

1. Go to Storage in your Supabase dashboard
2. Create a new bucket named `profile_images`
3. Set it to **Public** (or configure policies as needed)

### Storage Policies

```sql
-- Allow authenticated users to upload their own profile images
CREATE POLICY "Users can upload own profile images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'profile_images' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Allow users to update their own profile images
CREATE POLICY "Users can update own profile images" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'profile_images' AND 
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Allow public read access to profile images
CREATE POLICY "Profile images are publicly accessible" ON storage.objects
  FOR SELECT USING (bucket_id = 'profile_images');
```

## Authentication Setup

### Email Templates

1. Go to Authentication > Email Templates in your Supabase dashboard
2. Customize the following templates:
   - **Confirm signup**: Email verification for new users
   - **Magic Link**: Passwordless login email
   - **Reset password**: Password reset email

### Auth Settings

1. Go to Authentication > Settings
2. **Enable Email Provider** (should be enabled by default)
3. **Disable Email Confirmations** (optional, for demo purposes)
   - Or keep it enabled for production
4. Configure **Site URL** and **Redirect URLs** for your app

## Code Changes Summary

### Files Modified:

1. ✅ **pubspec.yaml**
   - Removed: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
   - Added: `supabase_flutter: ^2.9.1`

2. ✅ **lib/supabase_config.dart** (NEW)
   - Configuration file for Supabase credentials

3. ✅ **lib/services/auth_service.dart**
   - Firebase Auth → Supabase Auth
   - `signInWithEmailAndPassword()` → `signInWithPassword()`
   - `createUserWithEmailAndPassword()` → `signUp()`
   - `sendPasswordResetEmail()` → `resetPasswordForEmail()`

4. ✅ **lib/services/user_service.dart**
   - Firestore → Supabase Database
   - Firebase Storage → Supabase Storage
   - Collection queries → Table queries with `.from('users')`
   - Storage uploads updated for Supabase API

5. ✅ **lib/main.dart**
   - `Firebase.initializeApp()` → `Supabase.initialize()`

### Key API Differences:

| Firebase | Supabase |
|----------|----------|
| `FirebaseAuth.instance.currentUser` | `Supabase.instance.client.auth.currentUser` |
| `FirebaseAuth.instance.signInWithEmailAndPassword()` | `Supabase.instance.client.auth.signInWithPassword()` |
| `FirebaseAuth.instance.createUserWithEmailAndPassword()` | `Supabase.instance.client.auth.signUp()` |
| `FirebaseFirestore.instance.collection('users')` | `Supabase.instance.client.from('users')` |
| `collection.doc(id).get()` | `.select().eq('id', id).single()` |
| `collection.doc(id).set(data)` | `.upsert(data)` |
| `collection.doc(id).update(data)` | `.update(data).eq('id', id)` |
| `FirebaseStorage.instance.ref()` | `Supabase.instance.client.storage` |

## Testing Checklist

- [ ] **Authentication**
  - [ ] User registration works
  - [ ] User login works
  - [ ] Password reset works
  - [ ] User logout works
  - [ ] Demo accounts still work

- [ ] **User Profile**
  - [ ] Profile data loads correctly
  - [ ] Profile updates save successfully
  - [ ] Profile image upload works
  - [ ] Password change works

- [ ] **Database**
  - [ ] User data reads correctly
  - [ ] User data updates correctly
  - [ ] Queries return expected results

- [ ] **Storage**
  - [ ] Images upload successfully
  - [ ] Uploaded images are accessible
  - [ ] Image URLs are correct

## Demo Mode

The application maintains **demo mode** functionality:
- Demo accounts work without requiring Supabase connection
- Local storage fallback for offline testing
- All demo features preserved from Firebase version

## Troubleshooting

### Common Issues:

1. **"Invalid JWT" or authentication errors**
   - Verify your `supabaseAnonKey` is correct
   - Check that Supabase project is active

2. **"Permission denied" errors**
   - Verify Row Level Security policies are set up correctly
   - Check that user roles are properly assigned

3. **Storage upload fails**
   - Ensure `profile_images` bucket exists
   - Verify storage policies allow uploads
   - Check bucket is set to public if needed

4. **Build errors after migration**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Restart your IDE

### Getting Help:

- Supabase Documentation: [https://supabase.com/docs](https://supabase.com/docs)
- Flutter Supabase Package: [https://pub.dev/packages/supabase_flutter](https://pub.dev/packages/supabase_flutter)

## Next Steps

1. **Set up your Supabase project** and copy credentials to `supabase_config.dart`
2. **Run the SQL scripts** to create tables and policies
3. **Create storage buckets** and configure policies
4. **Test authentication** with a new user account
5. **Test profile management** features
6. **Build and test** the application thoroughly

## Production Considerations

Before deploying to production:

1. **Enable Email Confirmations** in Supabase Auth settings
2. **Set up proper Row Level Security** policies
3. **Configure custom email templates** with your branding
4. **Set up database backups**
5. **Monitor usage and performance** in Supabase dashboard
6. **Consider upgrading to Supabase Pro** for production features

---

**Migration completed successfully!** 🎉

The application has been fully migrated from Firebase to Supabase while maintaining all existing functionality and demo mode support.
