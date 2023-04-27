import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'adapty_ui_flutter_method_channel.dart';

abstract class AdaptyUiFlutterPlatform extends PlatformInterface {
  /// Constructs a AdaptyUiFlutterPlatform.
  AdaptyUiFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static AdaptyUiFlutterPlatform _instance = MethodChannelAdaptyUiFlutter();

  /// The default instance of [AdaptyUiFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelAdaptyUiFlutter].
  static AdaptyUiFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AdaptyUiFlutterPlatform] when
  /// they register themselves.
  static set instance(AdaptyUiFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
