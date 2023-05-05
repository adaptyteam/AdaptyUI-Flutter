import 'package:adapty_flutter/adapty_flutter.dart';

import 'models/adaptyui_view.dart';

abstract class AdaptyUIObserver {
  void paywallViewDidPressCloseButton(AdaptyUIView view) => view.dismiss();
  void paywallViewDidSelectProduct(AdaptyUIView view, AdaptyPaywallProduct product) {}
  void paywallViewDidStartPurchase(AdaptyUIView view, AdaptyPaywallProduct product) {}
  void paywallViewDidCancelPurchase(AdaptyUIView view, AdaptyPaywallProduct product);
  void paywallViewDidFinishPurchase(AdaptyUIView view, AdaptyPaywallProduct product, AdaptyProfile profile) {}
  void paywallViewDidFailPurchase(AdaptyUIView view, AdaptyPaywallProduct product, AdaptyError error) {}
  void paywallViewDidFinishRestore(AdaptyUIView view, AdaptyProfile profile);
  void paywallViewDidFailRestore(AdaptyUIView view, AdaptyError error) {}
  void paywallViewDidFailRendering(AdaptyUIView view, AdaptyError error);
  void paywallViewDidFailLoadingProducts(AdaptyUIView view, AdaptyIOSProductsFetchPolicy? fetchPolicy, AdaptyError error) {}
}
