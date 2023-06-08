import 'dart:convert' show json;
import 'package:adapty_ui_flutter/src/models/adaptyui_view.dart';
import 'package:flutter/services.dart';
import 'package:adapty_flutter/adapty_flutter.dart';

import 'adaptyui_observer.dart';
import 'adaptyui_logger.dart';

import 'constants/argument.dart';
import 'constants/method.dart';

import 'package:adapty_flutter/src/models/adapty_paywall.dart';
import 'package:adapty_flutter/src/models/adapty_paywall_product.dart';
import 'package:adapty_flutter/src/models/adapty_profile.dart';
import 'package:adapty_flutter/src/models/adapty_error.dart';
import 'package:adapty_flutter/src/models/adapty_sdk_native.dart';

typedef AdaptyUIProductsTitlesResolver = String? Function(String productId);

class AdaptyUI {
  static final AdaptyUI _instance = AdaptyUI._internal();

  factory AdaptyUI() {
    _instance._activateOnce();
    return _instance;
  }

  AdaptyUI._internal();

  static const String sdkVersion = '1.1.0';

  static const String _channelName = 'flutter.adapty.com/adapty_ui';
  static const MethodChannel _channel = MethodChannel(_channelName);

  bool _activated = false;
  AdaptyUIObserver? _observer;

  void _activateOnce() {
    if (_activated) return;

    _channel.setMethodCallHandler(_handleIncomingMethodCall);
    _activated = true;
  }

  Future<AdaptyUIView> createPaywallView({
    required AdaptyPaywall paywall,
    bool preloadProducts = false,
    AdaptyUIProductsTitlesResolver? productsTitlesResolver,
  }) async {
    Map<String, String>? productsTitles;

    if (productsTitlesResolver != null) {
      productsTitles = <String, String>{};

      for (var productId in paywall.vendorProductIds) {
        final title = productsTitlesResolver(productId);
        if (title != null) productsTitles[productId] = title;
      }
    } else {
      productsTitles = null;
    }

    final result = (await _invokeMethodHandlingErrors<String>(Method.createView, {
      Argument.paywall: json.encode(paywall.jsonValue),
      Argument.preloadProducts: preloadProducts,
      if (productsTitles != null) Argument.productsTitles: productsTitles,
    })) as String;

    final view = AdaptyUIViewJSONBuilder.fromJsonValue(json.decode(result));
    return view;
  }

  Future<void> presentPaywallView(AdaptyUIView view) async {
    return _invokeMethodHandlingErrors<void>(Method.presentView, {Argument.id: view.id});
  }

  Future<void> dismissPaywallView(AdaptyUIView view) async {
    return _invokeMethodHandlingErrors<void>(Method.dismissView, {Argument.id: view.id});
  }

  /// Registers the given object as an AdaptyUI events observer.
  void addObserver(AdaptyUIObserver observer) => _observer = observer;

  /// Unregisters the given observer.
  void removeObserver(AdaptyUIObserver observer) {
    if (_observer == observer) {
      _observer = null;
    }
  }

// ––––––– INTERNAL –––––––

  Future<T?> _invokeMethodHandlingErrors<T>(String method, [dynamic arguments]) async {
    AdaptyUILogger.write(AdaptyLogLevel.verbose, '--> AdaptyUI.$method()');

    try {
      final result = await _channel.invokeMethod<T>(method, arguments);
      AdaptyUILogger.write(AdaptyLogLevel.verbose, '<-- AdaptyUI.$method()');
      return result;
    } on PlatformException catch (e) {
      if (e.details != null) {
        final adaptyErrorData = json.decode(e.details);
        final adaptyError = AdaptyErrorJSONBuilder.fromJsonValue(adaptyErrorData);
        AdaptyUILogger.write(AdaptyLogLevel.verbose, '<-- AdaptyUI.$method() Adapty Error $adaptyError');
        throw adaptyError;
      } else {
        AdaptyUILogger.write(AdaptyLogLevel.verbose, '<-- AdaptyUI.$method() Error $e');
        rethrow;
      }
    }
  }

  Future<dynamic> _handleIncomingMethodCall(MethodCall call) {
    AdaptyUILogger.write(AdaptyLogLevel.verbose, 'handleIncomingCall ${call.method}');

    if (_observer == null) return Future.value(null);

    final view = AdaptyUIViewJSONBuilder.fromJsonValue(json.decode(call.arguments[Argument.view]));

    switch (call.method) {
      case Method.paywallViewDidPressCloseButton:
        _observer!.paywallViewDidPressCloseButton(view);
        break;
      case Method.paywallViewDidSelectProduct:
        final product = AdaptyPaywallProductJSONBuilder.fromJsonValue(json.decode(call.arguments[Argument.product]));
        _observer!.paywallViewDidSelectProduct(view, product);
        break;
      case Method.paywallViewDidStartPurchase:
        final product = AdaptyPaywallProductJSONBuilder.fromJsonValue(json.decode(call.arguments[Argument.product]));
        _observer!.paywallViewDidStartPurchase(view, product);
        break;
      case Method.paywallViewDidCancelPurchase:
        final product = AdaptyPaywallProductJSONBuilder.fromJsonValue(json.decode(call.arguments[Argument.product]));
        _observer!.paywallViewDidCancelPurchase(view, product);
        break;
      case Method.paywallViewDidFinishPurchase:
        final product = AdaptyPaywallProductJSONBuilder.fromJsonValue(json.decode(call.arguments[Argument.product]));
        final profile = AdaptyProfileJSONBuilder.fromJsonValue(json.decode(call.arguments[Argument.profile]));
        _observer!.paywallViewDidFinishPurchase(view, product, profile);
        break;
      case Method.paywallViewDidFailPurchase:
        final product = AdaptyPaywallProductJSONBuilder.fromJsonValue(json.decode(call.arguments[Argument.product]));
        final error = AdaptyErrorJSONBuilder.fromJsonValue(json.decode(call.arguments[Argument.error]));
        _observer!.paywallViewDidFailPurchase(view, product, error);
        break;
      case Method.paywallViewDidFinishRestore:
        final profile = AdaptyProfileJSONBuilder.fromJsonValue(json.decode(call.arguments[Argument.profile]));
        _observer!.paywallViewDidFinishRestore(view, profile);
        break;
      case Method.paywallViewDidFailRestore:
        final error = AdaptyErrorJSONBuilder.fromJsonValue(json.decode(call.arguments[Argument.error]));
        _observer!.paywallViewDidFailRestore(view, error);
        break;
      case Method.paywallViewDidFailRendering:
        final error = AdaptyErrorJSONBuilder.fromJsonValue(json.decode(call.arguments[Argument.error]));
        _observer!.paywallViewDidFailRendering(view, error);
        break;
      case Method.paywallViewDidFailLoadingProducts:
        AdaptyIOSProductsFetchPolicy? fetchPolicy;

        if (AdaptySDKNative.isIOS) {
          final String fetchPolicyString = call.arguments[Argument.fetchPolicy];

          switch (fetchPolicyString) {
            case 'wait_for_receipt_validation': // TODO: use Adapty-SDK
              fetchPolicy = AdaptyIOSProductsFetchPolicy.waitForReceiptValidation;
              break;
            default:
              fetchPolicy = AdaptyIOSProductsFetchPolicy.defaultPolicy;
              break;
          }
        } else {
          fetchPolicy = null;
        }

        final error = AdaptyErrorJSONBuilder.fromJsonValue(json.decode(call.arguments[Argument.error]));
        _observer!.paywallViewDidFailLoadingProducts(view, fetchPolicy, error);
        break;
      default:
        break;
    }

    return Future.value(null);
  }
}
