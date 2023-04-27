import 'package:flutter_test/flutter_test.dart';
import 'package:adapty_ui_flutter/adapty_ui_flutter.dart';
import 'package:adapty_ui_flutter/adapty_ui_flutter_platform_interface.dart';
import 'package:adapty_ui_flutter/adapty_ui_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAdaptyUiFlutterPlatform
    with MockPlatformInterfaceMixin
    implements AdaptyUiFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AdaptyUiFlutterPlatform initialPlatform = AdaptyUiFlutterPlatform.instance;

  test('$MethodChannelAdaptyUiFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAdaptyUiFlutter>());
  });

  test('getPlatformVersion', () async {
    AdaptyUiFlutter adaptyUiFlutterPlugin = AdaptyUiFlutter();
    MockAdaptyUiFlutterPlatform fakePlatform = MockAdaptyUiFlutterPlatform();
    AdaptyUiFlutterPlatform.instance = fakePlatform;

    expect(await adaptyUiFlutterPlugin.getPlatformVersion(), '42');
  });
}
