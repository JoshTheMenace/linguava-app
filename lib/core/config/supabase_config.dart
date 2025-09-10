class SupabaseConfig {
  static const String supabaseUrl = 'https://lsjqoszcmjzpimjjokip.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxzanFvc3pjbWp6cGltampva2lwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc0NzI1NzksImV4cCI6MjA3MzA0ODU3OX0.cn-Vxg4n7FoYCfipiVmnZIwp3x82kyX7eV6ohfcTc0Y';
  
  static bool get isConfigured => 
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}