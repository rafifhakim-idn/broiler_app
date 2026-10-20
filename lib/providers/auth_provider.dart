import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/profile_model.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _client = SupabaseConfig.client;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ProfileModel? _userProfile;
  ProfileModel? get userProfile => _userProfile;

  User? get currentUser => _client.auth.currentUser;

  // Cek Status Session saat aplikasi dibuka
  Future<void> checkCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user != null) {
      await fetchUserProfile(user.id);
    }
  }

  // Ambil data Profile dari tabel public.profiles
  Future<void> fetchUserProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      _userProfile = ProfileModel.fromJson(data);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetch profile: $e');
    }
  }

  // Register Akun Baru
  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        // Simpan metadata ke tabel public.profiles
        await _client.from('profiles').insert({
          'id': res.user!.id,
          'full_name': fullName,
          'role': role,
          'is_approved': role == 'super_admin', // Super Admin otomatis disetujui, staff butuh approval
        });
      }

      _isLoading = false;
      notifyListeners();
      return null; // Success
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Terjadi kesalahan sistem.';
    }
  }

  // Login
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        await fetchUserProfile(res.user!.id);
      }

      _isLoading = false;
      notifyListeners();
      return null; // Success
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Terjadi kesalahan sistem.';
    }
  }

  // Logout
  Future<void> signOut() async {
    await _client.auth.signOut();
    _userProfile = null;
    notifyListeners();
  }
}