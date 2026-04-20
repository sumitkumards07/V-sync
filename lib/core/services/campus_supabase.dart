import 'package:supabase_flutter/supabase_flutter.dart';

class CampusSupabaseConfig {
  const CampusSupabaseConfig({required this.url, required this.anonKey});

  final String url;
  final String anonKey;

  static CampusSupabaseConfig? fromEnvironment() {
    const appUrl = String.fromEnvironment('SUPABASE_URL');
    const appAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    const nextPublicUrl = String.fromEnvironment('NEXT_PUBLIC_SUPABASE_URL');
    const nextPublicPublishableKey = String.fromEnvironment(
      'NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY',
    );
    final url = appUrl.isNotEmpty ? appUrl : nextPublicUrl;
    final anonKey = appAnonKey.isNotEmpty
        ? appAnonKey
        : nextPublicPublishableKey;
    if (url.isEmpty || anonKey.isEmpty) return null;
    return CampusSupabaseConfig(url: url, anonKey: anonKey);
  }
}

class CampusSupabase {
  CampusSupabase._();

  static bool _initialized = false;
  static CampusSupabaseConfig? _config;

  static CampusSupabaseConfig? get config => _config;
  static bool get isConfigured => _config != null;
  static SupabaseClient? get client =>
      _initialized ? Supabase.instance.client : null;

  static Future<void> initialize() async {
    if (_initialized) return;
    final resolved = CampusSupabaseConfig.fromEnvironment();
    _config = resolved;
    if (resolved == null) return;
    await Supabase.initialize(url: resolved.url, anonKey: resolved.anonKey);
    _initialized = true;
  }
}
