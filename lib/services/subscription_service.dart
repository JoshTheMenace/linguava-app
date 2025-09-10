import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'auth_service.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final AuthService _authService = AuthService();
  
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  
  static const String premiumMonthlyId = 'premium_monthly';
  static const String premiumYearlyId = 'premium_yearly';
  
  static const Set<String> _productIds = {
    premiumMonthlyId,
    premiumYearlyId,
  };

  Future<bool> get isAvailable => _inAppPurchase.isAvailable();
  List<ProductDetails> get products => _products;

  Future<void> initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      if (kDebugMode) {
        print('In-app purchases not available');
      }
      return;
    }

    if (Platform.isIOS || Platform.isAndroid) {
      final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          if (kDebugMode) {
            print('Purchase stream error: $error');
          }
        },
      );

      await _loadProducts();
      await _restorePurchases();
    }
  }

  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        if (kDebugMode) {
          print('Products not found: ${response.notFoundIDs}');
        }
      }

      _products = response.productDetails;
      
      if (kDebugMode) {
        print('Loaded ${_products.length} products');
        for (final product in _products) {
          print('Product: ${product.id} - ${product.title} - ${product.price}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading products: $e');
      }
    }
  }

  Future<bool> purchaseSubscription(String productId) async {
    if (!await isAvailable) {
      throw Exception('In-app purchases not available');
    }

    final ProductDetails? productDetails = _products
        .cast<ProductDetails?>()
        .firstWhere(
          (product) => product?.id == productId,
          orElse: () => null,
        );

    if (productDetails == null) {
      throw Exception('Product not found: $productId');
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
      applicationUserName: _authService.currentUser?.id,
    );

    try {
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Purchase error: $e');
      }
      rethrow;
    }
  }

  Future<void> _restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      if (kDebugMode) {
        print('Error restoring purchases: $e');
      }
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (kDebugMode) {
      print('Purchase status: ${purchaseDetails.status}');
      print('Product ID: ${purchaseDetails.productID}');
    }

    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        // Handle pending purchase
        break;
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _completePurchase(purchaseDetails);
        break;
      case PurchaseStatus.error:
        if (kDebugMode) {
          print('Purchase error: ${purchaseDetails.error}');
        }
        break;
      case PurchaseStatus.canceled:
        if (kDebugMode) {
          print('Purchase canceled');
        }
        break;
    }

    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  Future<void> _completePurchase(PurchaseDetails purchaseDetails) async {
    try {
      if (_productIds.contains(purchaseDetails.productID)) {
        await _authService.updateSubscriptionStatus(true);
        
        if (kDebugMode) {
          print('Premium subscription activated');
        }
      }
      
      await _verifyPurchaseWithServer(purchaseDetails);
    } catch (e) {
      if (kDebugMode) {
        print('Error completing purchase: $e');
      }
    }
  }

  Future<void> _verifyPurchaseWithServer(PurchaseDetails purchaseDetails) async {
    if (!_authService.isSupabaseConfigured() || !_authService.isAuthenticated) {
      return;
    }

    try {
      await _authService.supabase.from('purchases').insert({
        'user_id': _authService.currentUser!.id,
        'product_id': purchaseDetails.productID,
        'purchase_id': purchaseDetails.purchaseID,
        'transaction_date': DateTime.now().toIso8601String(),
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'verification_data': purchaseDetails.verificationData.localVerificationData,
        'server_verification_data': purchaseDetails.verificationData.serverVerificationData,
      });
      
      if (kDebugMode) {
        print('Purchase verified with server');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying purchase with server: $e');
      }
    }
  }

  Future<bool> checkSubscriptionStatus() async {
    if (!_authService.isAuthenticated) {
      return false;
    }

    try {
      final userProfile = await _authService.getUserProfile();
      return userProfile?['is_premium'] ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking subscription status: $e');
      }
      return false;
    }
  }

  Future<void> restorePurchases() async {
    await _restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
  }
}