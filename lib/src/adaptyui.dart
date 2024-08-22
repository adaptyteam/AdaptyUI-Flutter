import 'dart:convert' show json;
import 'package:adapty_ui_flutter/src/models/adaptyui_action.dart';
import 'package:adapty_ui_flutter/src/models/adaptyui_dialog.dart';
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

typedef AdaptyUIProductsTitlesResolver = String? Function(String productId);

class AdaptyUI {
  static final AdaptyUI _instance = AdaptyUI._internal();

  factory AdaptyUI() {
    _instance._activateOnce();
    return _instance;
  }

  AdaptyUI._internal();

  static const String sdkVersion = '2.1.3';

  static const String _channelName = 'flutter.adapty.com/adapty_ui';
  static const MethodChannel _channel = MethodChannel(_channelName);

  bool _activated = false;
  AdaptyUIObserver? _observer;

  void _activateOnce() {
    if (_activated) return;

    _channel.setMethodCallHandler(_handleIncomingMethodCall);
    _activated = true;
  }

  /// Right after receiving ``AdaptyPaywall``, you can create the corresponding ``AdaptyUIView`` to present it afterwards.
  ///
  /// **Parameters**
  /// - [paywall]: an [AdaptyPaywall] object, for which you are trying to get a controller.
  /// - [preloadProducts]: If you pass `true`, `AdaptyUI` will automatically prefetch the required products at the moment of view assembly.
  /// - [androidPersonalizedOffers]: A map that determines whether the price for a given product is personalized.
  /// Key is a string containing `basePlanId` and `vendorProductId` separated by `:`. If `basePlanId` is `null` or empty, only `vendorProductId` is used.
  /// Example: `basePlanId:vendorProductId` or `vendorProductId`.
  /// [Read more](https://developer.android.com/google/play/billing/integrate#personalized-price)
  ///
  /// **Returns**
  /// - an [AdaptyUIView] object, representing the requested paywall screen.
  Future<AdaptyUIView> createPaywallView({
    required AdaptyPaywall paywall,
    required String locale,
    bool preloadProducts = false,
    Map<String, String>? customTags,
    Map<String, bool>? androidPersonalizedOffers,
  }) async {
    final result = (await _invokeMethodHandlingErrors<String>(Method.createView, {
      Argument.paywall: json.encode(paywall.jsonValue),
      Argument.locale: locale,
      Argument.preloadProducts: preloadProducts,
      if (customTags != null) Argument.customTags: customTags,
      if (androidPersonalizedOffers != null) Argument.personalizedOffers: androidPersonalizedOffers,
    })) as String;

    final view = AdaptyUIViewJSONBuilder.fromJsonValue(json.decode(result));
    return view;
  }

  /// Call this function if you wish to present the view.
  ///
  /// **Parameters**
  /// - [view]: an [AdaptyUIView] object, for which is representing the view.
  Future<void> presentPaywallView(AdaptyUIView view) async {
    return _invokeMethodHandlingErrors<void>(Method.presentView, {Argument.id: view.id});
  }

  /// Call this function if you wish to dismiss the view.
  ///
  /// **Parameters**
  /// - [view]: an [AdaptyUIView] object, for which is representing the view.
  Future<void> dismissPaywallView(AdaptyUIView view) async {
    return _invokeMethodHandlingErrors<void>(Method.dismissView, {Argument.id: view.id});
  }

  /// Call this function if you wish to present the dialog.
  ///
  /// **Parameters**
  /// - [view]: an [AdaptyUIView] object, for which is representing the view.
  /// - [dialog]: an [AdaptyUIDialog] object, description of the desired dialog.
  Future<void> showDialog(AdaptyUIView view, AdaptyUIDialog dialog) async {
    final dismissActionIndex = await _invokeMethodHandlingErrors<int?>(Method.showDialog, {
      Argument.id: view.id,
      Argument.configuration: json.encode(dialog.jsonValue),
    });

    switch (dismissActionIndex) {
      case 0:
        dialog.defaultAction.onPressed.call();
        break;
      case 1:
        dialog.secondaryAction?.onPressed.call();
        break;
      default:
        break;
    }
  }

  /// Registers the given object as an [AdaptyUI] events observer.
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
      case Method.paywallViewDidPerformAction:
        final action = AdaptyUIActionJSONBuilder.fromJsonValue(json.decode(call.arguments[Argument.action]));
        _observer!.paywallViewDidPerformAction(view, action);
        break;
      case Method.paywallViewDidPerformSystemBackAction:
        _observer!.paywallViewDidPerformAction(
          view,
          const AdaptyUIAction(AdaptyUIActionType.androidSystemBack, null),
        );
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
      case Method.paywallViewDidStartRestore:
        _observer!.paywallViewDidStartRestore(view);
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
        final error = AdaptyErrorJSONBuilder.fromJsonValue(json.decode(call.arguments[Argument.error]));
        _observer!.paywallViewDidFailLoadingProducts(view, error);
        break;
      default:
        break;
    }

    return Future.value(null);
  }
}
