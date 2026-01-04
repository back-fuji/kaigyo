import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/purchase_repository.dart';

/// 購入リポジトリの実装
///
/// SharedPreferencesを使用して購入状態を永続化します。
class PurchaseRepositoryImpl implements PurchaseRepository {
  static const String _adRemovedKey = 'purchase_ad_removed';
  static const String _pageLimit10Key = 'purchase_page_limit_10';
  static const String _pageLimit20Key = 'purchase_page_limit_20';

  @override
  Future<bool> isAdRemovedPurchased() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_adRemovedKey) ?? false;
    } catch (e) {
      debugPrint('Error getting ad removed purchase status: $e');
      return false;
    }
  }

  @override
  Future<void> setAdRemovedPurchased(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_adRemovedKey, value);
    } catch (e) {
      debugPrint('Error setting ad removed purchase status: $e');
    }
  }

  @override
  Future<bool> isPageLimit10Purchased() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_pageLimit10Key) ?? false;
    } catch (e) {
      debugPrint('Error getting page limit 10 purchase status: $e');
      return false;
    }
  }

  @override
  Future<void> setPageLimit10Purchased(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pageLimit10Key, value);
    } catch (e) {
      debugPrint('Error setting page limit 10 purchase status: $e');
    }
  }

  @override
  Future<bool> isPageLimit20Purchased() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_pageLimit20Key) ?? false;
    } catch (e) {
      debugPrint('Error getting page limit 20 purchase status: $e');
      return false;
    }
  }

  @override
  Future<void> setPageLimit20Purchased(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pageLimit20Key, value);
    } catch (e) {
      debugPrint('Error setting page limit 20 purchase status: $e');
    }
  }

  @override
  Future<int> getMaxPageCount() async {
    final isLimit20 = await isPageLimit20Purchased();
    if (isLimit20) {
      return 20;
    }
    final isLimit10 = await isPageLimit10Purchased();
    if (isLimit10) {
      return 10;
    }
    return 3; // デフォルト
  }
}
