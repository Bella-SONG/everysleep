import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static late SupabaseClient _client;
  
  static SupabaseClient get client => _client;
  
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Supabase URL or Anon Key not found in .env file');
    }
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: kDebugMode,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
        autoRefreshToken: true,
      ),
    );
    
    _client = Supabase.instance.client;
    
    if (kDebugMode) {
      print('✅ Supabase initialized successfully');
      print('📍 URL: $supabaseUrl');
    }
  }
  
  // Auth helpers
  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
  
  // Database helpers
  static PostgrestQueryBuilder from(String table) => _client.from(table);
  static PostgrestQueryBuilder get tracks => from('tracks');
  static PostgrestQueryBuilder get themes => from('themes');
  static PostgrestQueryBuilder get userMoodLogs => from('user_mood_logs');
  
  // Storage helpers
  static SupabaseStorageClient get storage => _client.storage;
  static StorageFileApi get audioStorage => 
      storage.from('audio-tracks');
  static StorageFileApi get imageStorage => 
      storage.from('everysleeptrack');
  
  // 이미지 URL 헬퍼 (CDN 사용 - 재생화면용 고화질)
  static String getImageUrl(String imagePath) {
    return 'https://everysleep.b-cdn.net/images/$imagePath';
  }
  
  // 썸네일 이미지 URL 헬퍼 (Supabase Storage 사용 - 비용 절약)
  static String getThumbnailUrl(String imagePath) {
    return _client.storage.from('everysleeptrack').getPublicUrl('thumbnails/$imagePath');
  }
}