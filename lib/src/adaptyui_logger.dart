import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:adapty_ui_flutter/adapty_ui_flutter.dart';

class AdaptyUILogger {
  static void write(AdaptyLogLevel level, String message) {
    AdaptyLogger.write(level, '[UI v${AdaptyUI.sdkVersion}] $message');
  }
}
