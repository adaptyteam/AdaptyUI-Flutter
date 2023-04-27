import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adapty_ui_flutter/adapty_ui_flutter_method_channel.dart';

void main() {
  MethodChannelAdaptyUiFlutter platform = MethodChannelAdaptyUiFlutter();
  const MethodChannel channel = MethodChannel('adapty_ui_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
