import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:adapty_ui_flutter_example/purchases_observer.dart';
import 'package:flutter/cupertino.dart';

import 'paywalls_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    PurchasesObserver().initialize();

    super.initState();
  }

  void _presentAdaptyError(AdaptyError error) {}

  void _presentCustomError(Object error) {}

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      home: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Welcome to Adapty UI Flutter!'),
        ),
        child: PaywallsList(
          adaptyErrorCallback: _presentAdaptyError,
          customErrorCallback: _presentCustomError,
        ),
      ),
    );
  }
}
