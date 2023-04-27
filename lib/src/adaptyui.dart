import 'dart:convert' show json;
import 'package:adapty_ui_flutter/src/models/adaptyui_view_configuration.dart';
import 'package:flutter/services.dart';
import 'package:adapty_flutter/adapty_flutter.dart';

import 'adaptyui_logger.dart';

import 'constants/argument.dart';
import 'constants/method.dart';

import 'models/private/adaptyui_error_json_builder.dart';

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

  void _activateOnce() {
    if (_activated) return;

    _channel.setMethodCallHandler(_handleIncomingMethodCall);
    _activated = true;
  }

  Future<String> createPaywallView({required AdaptyPaywall paywall}) async {
    final result = (await _invokeMethodHandlingErrors<String>(Method.createView, {
      Argument.paywallId: paywall.id,
    })) as String;

    return json.decode(result);
  }

  Future<void> presentPaywallView({required String instanceId}) async {
    return _invokeMethodHandlingErrors<void>(Method.presentView, {Argument.instanceId: instanceId});
  }

  Future<void> dismissPaywallView({required String instanceId}) async {
    return _invokeMethodHandlingErrors<void>(Method.dismissView, {Argument.instanceId: instanceId});
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
