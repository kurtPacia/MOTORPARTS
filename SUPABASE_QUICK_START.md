# Supabase Quick Start Guide

## 🚀 Getting Started with Supabase

This document provides a quick reference for developers working with Supabase in the FKK Enterprise Motorshop app.

## 📝 Configuration

### 1. Update Credentials

Edit `lib/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
}
```

**Where to find these:**
1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Select your project
3. Go to Settings > API
4. Copy the **Project URL** and **anon/public** key

## 🔑 Authentication

### Sign Up
```dart
final response = await Supabase.instance.client.auth.signUp(
  email: 'user@example.com',
  password: 'password123',
  data: {'full_name': 'John Doe', 'role': 'customer'},
);
```

### Sign In
```dart
final response = await Supabase.instance.client.auth.signInWithPassword(
  email: 'user@example.com',
  password: 'password123',
);
```

### Sign Out
```dart
await Supabase.instance.client.auth.signOut();
```

### Get Current User
```dart
final user = Supabase.instance.client.auth.currentUser;
final userId = user?.id;
final userEmail = user?.email;
```

### Password Reset
```dart
await Supabase.instance.client.auth.resetPasswordForEmail('user@example.com');
```

## 💾 Database Operations

### Insert Data
```dart
await Supabase.instance.client
  .from('users')
  .insert({
    'id': userId,
    'name': 'John Doe',
    'email': 'user@example.com',
    'role': 'customer',
  });
```

### Update Data
```dart
await Supabase.instance.client
  .from('users')
  .update({'name': 'Jane Doe'})
  .eq('id', userId);
```

### Upsert (Insert or Update)
```dart
await Supabase.instance.client
  .from('users')
  .upsert({
    'id': userId,
    'name': 'John Doe',
    'email': 'user@example.com',
  });
```

### Select Single Record
```dart
final response = await Supabase.instance.client
  .from('users')
  .select()
  .eq('id', userId)
  .single();

final userData = response; // Map<String, dynamic>
```

### Select Multiple Records
```dart
final response = await Supabase.instance.client
  .from('products')
  .select()
  .eq('category', 'engine')
  .order('price');

final products = response as List<dynamic>;
```

### Select with Filters
```dart
final response = await Supabase.instance.client
  .from('products')
  .select()
  .eq('category', 'engine')
  .gte('price', 100)
  .lte('price', 500)
  .order('name');
```

### Delete Data
```dart
await Supabase.instance.client
  .from('users')
  .delete()
  .eq('id', userId);
```

## 📦 Storage Operations

### Upload File
```dart
final file = File(imagePath);
await Supabase.instance.client.storage
  .from('profile_images')
  .upload(
    'user_$userId.jpg',
    file,
    fileOptions: const FileOptions(upsert: true),
  );
```

### Get Public URL
```dart
final imageUrl = Supabase.instance.client.storage
  .from('profile_images')
  .getPublicUrl('user_$userId.jpg');
```

### Download File
```dart
final bytes = await Supabase.instance.client.storage
  .from('profile_images')
  .download('user_$userId.jpg');
```

### Delete File
```dart
await Supabase.instance.client.storage
  .from('profile_images')
  .remove(['user_$userId.jpg']);
```

## 🔒 Row Level Security (RLS)

### Enable RLS on a Table
```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
```

### Common RLS Policies

**Allow users to read their own data:**
```sql
CREATE POLICY "Users can read own data" ON users
  FOR SELECT USING (auth.uid() = id);
```

**Allow users to update their own data:**
```sql
CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid() = id);
```

**Allow public read access:**
```sql
CREATE POLICY "Public read access" ON products
  FOR SELECT USING (true);
```

**Admin-only access:**
```sql
CREATE POLICY "Only admins can modify" ON products
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid() AND users.role = 'admin'
    )
  );
```

## 🎯 Common Patterns

### Check if User Exists
```dart
try {
  final response = await Supabase.instance.client
    .from('users')
    .select()
    .eq('email', email)
    .maybeSingle();
  
  if (response != null) {
    // User exists
  }
} catch (e) {
  // Handle error
}
```

### Realtime Subscriptions
```dart
final subscription = Supabase.instance.client
  .from('orders')
  .stream(primaryKey: ['id'])
  .eq('customer_id', userId)
  .listen((data) {
    // Handle real-time updates
    print('Orders updated: $data');
  });

// Don't forget to cancel when done
subscription.cancel();
```

### Pagination
```dart
final page = 0;
final pageSize = 20;

final response = await Supabase.instance.client
  .from('products')
  .select()
  .range(page * pageSize, (page + 1) * pageSize - 1);
```

## 🐛 Error Handling

### Auth Errors
```dart
try {
  await Supabase.instance.client.auth.signInWithPassword(
    email: email,
    password: password,
  );
} on AuthException catch (e) {
  if (e.message.contains('Invalid login credentials')) {
    // Show error to user
  }
}
```

### Database Errors
```dart
try {
  await Supabase.instance.client
    .from('users')
    .insert(data);
} on PostgrestException catch (e) {
  print('Database error: ${e.message}');
}
```

## 📊 Useful SQL Functions

### Create Updated At Trigger
```sql
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

## 🔍 Testing Checklist

- [ ] Test user registration
- [ ] Test user login
- [ ] Test password reset
- [ ] Test profile updates
- [ ] Test image uploads
- [ ] Test data queries
- [ ] Test RLS policies
- [ ] Test offline behavior

## 📚 Helpful Resources

- **Supabase Docs:** [https://supabase.com/docs](https://supabase.com/docs)
- **Flutter Package:** [https://pub.dev/packages/supabase_flutter](https://pub.dev/packages/supabase_flutter)
- **API Reference:** [https://supabase.com/docs/reference/dart](https://supabase.com/docs/reference/dart)
- **SQL Editor:** Available in your Supabase dashboard

## 💡 Tips

1. **Use .maybeSingle() instead of .single()** when a record might not exist
2. **Always enable RLS** on your tables for security
3. **Use .upsert()** when you're not sure if a record exists
4. **Set timeouts** for operations that might fail in demo mode
5. **Cache frequently accessed data** to improve performance
6. **Test with airplane mode** to ensure offline fallbacks work

## 🚨 Common Issues

### "JWT expired" error
- The user's session has expired
- Call `await Supabase.instance.client.auth.refreshSession()`

### "Row Level Security policy violation"
- Check that RLS policies allow the operation
- Verify user is authenticated for protected tables

### Storage upload fails
- Ensure bucket exists and is properly configured
- Check storage policies allow the upload
- Verify file size is within limits

### Can't connect to Supabase
- Verify URL and anon key are correct
- Check internet connection
- Ensure Supabase project is active (not paused)

---

**Happy coding with Supabase!** 🎉
