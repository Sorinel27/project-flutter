import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../state/app_state.dart';
import 'profile_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isLogin = true;
  bool _busy = false;
  String? _profileEnsuredForUserId;
  bool _ensuringProfile = false;

  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String _redirectToForGoogle() {
    if (kIsWeb) return Uri.base.origin;
    // Supabase expects deep links in the format scheme://host (no path).
    return 'com.example.project_flutter://login-callback';
  }

  Future<void> _ensureProfileOnce(User user) async {
    if (_ensuringProfile) return;
    if (_profileEnsuredForUserId == user.id) return;

    _ensuringProfile = true;
    try {
      await ensureProfile();
      _profileEnsuredForUserId = user.id;
    } catch (e) {
      // If the DB table/RLS isn't configured yet, don't crash the app.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile sync failed: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      _ensuringProfile = false;
    }
  }

  Future<void> _handleAuth(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth error: $e'), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        centerTitle: true,
        actions: const [],
      ),
      body: AnimatedBuilder(
        animation: authModel,
        builder: (context, child) {
          if (authModel.isSignedIn) {
            final user = authModel.user!;
            // Ensure DB profile exists (handles OAuth sign-ins too), but never crash on failure.
            unawaited(_ensureProfileOnce(user));
            return _SignedInView(
              email: user.email ?? 'Unknown',
              userId: user.id,
              onSignOut: () => _handleAuth(() async {
                HapticFeedback.selectionClick();
                await authModel.signOut();
                _profileEnsuredForUserId = null;
              }),
            );
          }

          return _SignedOutView(
            isLogin: _isLogin,
            busy: _busy,
            emailController: _email,
            passwordController: _password,
            onToggleMode: () {
              HapticFeedback.selectionClick();
              setState(() => _isLogin = !_isLogin);
            },
            onSubmit: () => _handleAuth(() async {
              final email = _email.text.trim();
              final password = _password.text;
              if (email.isEmpty || password.isEmpty) {
                throw const FormatException('Email and password are required');
              }

              HapticFeedback.lightImpact();
              if (_isLogin) {
                await authModel.signInWithPassword(email: email, password: password);
              } else {
                await authModel.signUp(email: email, password: password);
              }

              await ensureProfile();
            }),
            onGoogle: () => _handleAuth(() async {
              HapticFeedback.lightImpact();
              await authModel.signInWithGoogle(redirectTo: _redirectToForGoogle());
              // Session will be available after the OAuth redirect.
            }),
          );
        },
      ),
    );
  }
}

class _SignedInView extends StatelessWidget {
  final String email;
  final String userId;
  final VoidCallback onSignOut;

  const _SignedInView({
    required this.email,
    required this.userId,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(email, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 6),
              Text('User ID: $userId', style: TextStyle(color: Theme.of(context).hintColor)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: onSignOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignedOutView extends StatelessWidget {
  final bool isLogin;
  final bool busy;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onToggleMode;
  final VoidCallback onSubmit;
  final VoidCallback onGoogle;

  const _SignedOutView({
    required this.isLogin,
    required this.busy,
    required this.emailController,
    required this.passwordController,
    required this.onToggleMode,
    required this.onSubmit,
    required this.onGoogle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isLogin ? 'Login' : 'Create account', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                autofillHints: isLogin ? const [AutofillHints.password] : const [AutofillHints.newPassword],
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: busy ? null : onSubmit,
                  child: busy
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isLogin ? 'Login' : 'Register'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: busy ? null : onGoogle,
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Continue with Google'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: busy ? null : onToggleMode,
                child: Text(isLogin ? 'No account? Register' : 'Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
