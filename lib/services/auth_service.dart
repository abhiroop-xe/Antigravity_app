import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Stream<AuthState> get authStateChanges => _supabase?.auth.onAuthStateChange ?? const Stream.empty();
  User? get currentUser => _supabase?.auth.currentUser;

  Future<AuthResponse> signIn(String email, String password) async {
    if (_supabase == null) throw const AuthException('Supabase not initialized. Use Demo Login.');
    return await _supabase!.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp(String email, String password) async {
    if (_supabase == null) throw const AuthException('Supabase not initialized. Use Demo Login.');
    return await _supabase!.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase?.auth.signOut();
  }
}
