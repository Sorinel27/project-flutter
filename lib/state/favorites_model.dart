import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesModel extends ChangeNotifier {
  static const _prefsKey = 'favoriteProductIds';

  final Set<String> _favoriteIds = <String>{};
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final ids = _prefs?.getStringList(_prefsKey) ?? const <String>[];
    _favoriteIds
      ..clear()
      ..addAll(ids);
    notifyListeners();
  }

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  int get count => _favoriteIds.length;

  Future<void> toggleFavorite(String productId) async {
    if (!_favoriteIds.add(productId)) {
      _favoriteIds.remove(productId);
    }
    await _prefs?.setStringList(_prefsKey, _favoriteIds.toList(growable: false));
    notifyListeners();
  }
}
