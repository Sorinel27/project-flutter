import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> ensureProfile() async {
  final client = Supabase.instance.client;
  final user = client.auth.currentUser;
  if (user == null) return;

  // Requires a `profiles` table (see supabase/schema.sql).
  await client.from('profiles').upsert(
    {
      'id': user.id,
      'email': user.email,
      'updated_at': DateTime.now().toIso8601String(),
    },
    onConflict: 'id',
  );
}
