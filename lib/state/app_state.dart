import 'cart_model.dart';
import 'favorites_model.dart';
import 'auth_model.dart';
import 'theme_model.dart';

import '../config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final cartModel = CartModel();
final favoritesModel = FavoritesModel();
final themeModel = ThemeModel();
late final AuthModel authModel;

Future<void> initAppState() async {
  await Future.wait([
    cartModel.init(),
    favoritesModel.init(),
    themeModel.init(),
  ]);

  if (SupabaseConfig.isConfigured) {
    authModel = AuthModel(Supabase.instance.client);
  }
}
