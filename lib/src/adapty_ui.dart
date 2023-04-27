import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/services.dart';

class AdaptyUI {
  static final AdaptyUI _instance = AdaptyUI._internal();

  factory AdaptyUI() {
    return _instance;
  }

  AdaptyUI._internal();

  static const String sdkVersion = '2.4.3';

  static const String _channelName = 'flutter.adapty.com/adapty_ui';
  static const MethodChannel _channel = MethodChannel(_channelName);

  /// Use this method to initialize the Adapty UI.
  void activate() {
    _channel.setMethodCallHandler(_handleIncomingMethodCall);
  }

  Future<dynamic> _handleIncomingMethodCall(MethodCall call) {
    AdaptyLogger.write(AdaptyLogLevel.verbose, 'handleIncomingCall ${call.method}');

    return Future.value(null);
  }
}
