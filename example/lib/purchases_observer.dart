import 'dart:async' show Future;
import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:adapty_ui_flutter/adapty_ui_flutter.dart';
import 'package:adapty_ui_flutter/src/models/adaptyui_action.dart';

class PurchasesObserver with AdaptyUIObserver {
  void Function(AdaptyError)? onAdaptyErrorOccurred;
  void Function(Object)? onUnknownErrorOccurred;

  final adapty = Adapty();
  final adaptyUI = AdaptyUI();

  static final PurchasesObserver _instance = PurchasesObserver._internal();

  factory PurchasesObserver() {
    return _instance;
  }

  PurchasesObserver._internal();

  Future<void> initialize() async {
    try {
      adapty.setLogLevel(AdaptyLogLevel.verbose);
      adapty.activate();

      AdaptyUI().addObserver(this);
    } on AdaptyError catch (adaptyError) {
      onAdaptyErrorOccurred?.call(adaptyError);
    } catch (e) {
      onUnknownErrorOccurred?.call(e);
    }
  }

  Future<AdaptyProfile?> callGetProfile() async {
    try {
      final result = await adapty.getProfile();
      return result;
    } on AdaptyError catch (adaptyError) {
      onAdaptyErrorOccurred?.call(adaptyError);
    } catch (e) {
      onUnknownErrorOccurred?.call(e);
    }

    return null;
  }

  Future<AdaptyPaywall?> callGetPaywall(String paywallId, String? locale) async {
    try {
      final result = await adapty.getPaywall(id: paywallId, locale: locale);
      return result;
    } on AdaptyError catch (adaptyError) {
      onAdaptyErrorOccurred?.call(adaptyError);
    } catch (e) {
      onUnknownErrorOccurred?.call(e);
    }

    return null;
  }

  Future<List<AdaptyPaywallProduct>?> callGetPaywallProducts(AdaptyPaywall paywall) async {
    try {
      final result = await adapty.getPaywallProducts(paywall: paywall);
      return result;
    } on AdaptyError catch (adaptyError) {
      onAdaptyErrorOccurred?.call(adaptyError);
    } catch (e) {
      onUnknownErrorOccurred?.call(e);
    }

    return null;
  }

  @override
  void paywallViewDidPerformAction(AdaptyUIView view, AdaptyUIAction action) {
    print('#Example# paywallViewDidPerformAction ${action.type} of $view');

    switch (action.type) {
      case AdaptyUIActionType.close:
        view.dismiss();
        break;
      default:
        break;
    }
  }

  @override
  void paywallViewDidCancelPurchase(AdaptyUIView view, AdaptyPaywallProduct product) {
    print('#Example# paywallViewDidCancelPurchase of $view');
  }

  @override
  void paywallViewDidFailLoadingProducts(AdaptyUIView view, AdaptyError error) {
    print('#Example# paywallViewDidFailLoadingProducts of $view, error = $error');
  }

  @override
  void paywallViewDidFailRendering(AdaptyUIView view, AdaptyError error) {
    print('#Example# paywallViewDidFailRendering of $view, error = $error');
  }

  @override
  void paywallViewDidFinishPurchase(AdaptyUIView view, AdaptyPaywallProduct product, AdaptyProfile profile) {
    print('#Example# paywallViewDidFinishPurchase of $view');

    if (profile.accessLevels['premium']?.isActive ?? false) {
      view.dismiss();
    }
  }

  @override
  void paywallViewDidFailPurchase(AdaptyUIView view, AdaptyPaywallProduct product, AdaptyError error) {
    print('#Example# paywallViewDidFailPurchase of $view, error = $error');
  }

  @override
  void paywallViewDidFinishRestore(AdaptyUIView view, AdaptyProfile profile) {
    print('#Example# paywallViewDidFinishRestore of $view');

    if (profile.accessLevels['premium']?.isActive ?? false) {
      view.dismiss();
    }
  }

  @override
  void paywallViewDidFailRestore(AdaptyUIView view, AdaptyError error) {
    print('#Example# paywallViewDidFailRestore of $view, error = $error');
  }

  @override
  void paywallViewDidSelectProduct(AdaptyUIView view, AdaptyPaywallProduct product) {
    print('#Example# paywallViewDidSelectProduct of $view');
  }

  @override
  void paywallViewDidStartPurchase(AdaptyUIView view, AdaptyPaywallProduct product) {
    print('#Example# paywallViewDidStartPurchase of $view');
  }
}
