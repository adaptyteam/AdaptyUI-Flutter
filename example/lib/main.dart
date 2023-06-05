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

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      home: MainView(),
    );
  }
}

class MainView extends StatelessWidget {
  const MainView({super.key});

  Future<void> _showErrorDialog(BuildContext context, String title, String message, String? details) {
    return showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Column(
          children: [
            Text(message),
            if (details != null) Text(details),
          ],
        ),
        actions: [
          CupertinoButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Welcome to Adapty UI Flutter!'),
      ),
      child: PaywallsList(
        adaptyErrorCallback: (e) => _showErrorDialog(context, 'Error code ${e.code}!', e.message, e.detail),
        customErrorCallback: (e) => _showErrorDialog(context, 'Unknown error!', e.toString(), null),
      ),
    );
  }
}
