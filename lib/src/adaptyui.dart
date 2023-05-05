import 'dart:convert' show json;
import 'package:adapty_ui_flutter/src/models/adaptyui_view.dart';
import 'package:flutter/services.dart';
import 'package:adapty_flutter/adapty_flutter.dart';

import 'adaptyui_observer.dart';
import 'adaptyui_logger.dart';

import 'constants/argument.dart';
import 'constants/method.dart';

import 'models/private/adaptyui_error_json_builder.dart';
import 'package:adapty_flutter/src/models/adapty_paywall.dart';
import 'package:adapty_flutter/src/models/adapty_paywall_product.dart';

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

  Future<AdaptyUIView> createPaywallView({required AdaptyPaywall paywall, List<AdaptyPaywallProduct>? products}) async {
    final result = (await _invokeMethodHandlingErrors<String>(Method.createView, {
      Argument.paywall: json.encode(paywall.jsonValue),
      if (products != null) Argument.products: products.map((e) => e.jsonValue).toList(),
    })) as String;

    return json.decode(result);
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
        final adaptyError = AdaptyUIErrorJSONBuilder.fromJsonValue(adaptyErrorData);
        AdaptyUILogger.write(AdaptyLogLevel.verbose, '<-- AdaptyUI.$method() Adapty Error $adaptyError');
        throw adaptyError;
      } else {
        AdaptyUILogger.write(AdaptyLogLevel.verbose, '<-- AdaptyUI.$method() Error $e');
        throw e;
      }
    }
  }

  Future<dynamic> _handleIncomingMethodCall(MethodCall call) {
    AdaptyUILogger.write(AdaptyLogLevel.verbose, 'handleIncomingCall ${call.method}');

    return Future.value(null);
  }
}
