
import 'adapty_ui_flutter_platform_interface.dart';

class AdaptyUiFlutter {
  Future<String?> getPlatformVersion() {
    return AdaptyUiFlutterPlatform.instance.getPlatformVersion();
  }
}
