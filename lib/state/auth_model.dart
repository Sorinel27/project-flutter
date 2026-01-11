import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthModel extends ChangeNotifier {
  final SupabaseClient _client;
  late final StreamSubscription<AuthState> _sub;

  AuthModel(this._client) {
    _sub = _client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  User? get user => _client.auth.currentUser;
  Session? get session => _client.auth.currentSession;
  bool get isSignedIn => user != null;

  Future<void> disposeAsync() async {
    await _sub.cancel();
  }

  @override
  void dispose() {
    // ignore: discarded_futures
    _sub.cancel();
    super.dispose();
  }

  Future<AuthResponse> signInWithPassword({required String email, required String password}) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({required String email, required String password}) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<bool> signInWithGoogle({String? redirectTo}) {
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
      authScreenLaunchMode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    );
  }
}
