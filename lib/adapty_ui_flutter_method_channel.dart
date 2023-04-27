import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'adapty_ui_flutter_platform_interface.dart';

/// An implementation of [AdaptyUiFlutterPlatform] that uses method channels.
class MethodChannelAdaptyUiFlutter extends AdaptyUiFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('adapty_ui_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
