// Supabase configuration file
// Replace these values with your actual Supabase project credentials
// You can find these in your Supabase project settings

class SupabaseConfig {
  // Get these from: https://app.supabase.com/project/YOUR_PROJECT/settings/api
  static const String supabaseUrl = 'https://mqoovnoerykhzcmfgwuy.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1xb292bm9lbmp4aGV6bWZnd3V5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwMjE5NTYsImV4cCI6MjA3OTU5Nzk1Nn0.ORIXfYLn8Ykq9OX2nDO9yLVLCvhRm7e5CEGpUCbZ6NA';

  // Optional: You can add other configuration here
  static const String authCallbackUrlHostname =
      'YOUR_APP_SCHEME'; // e.g., 'com.yourcompany.motorshop'
}
