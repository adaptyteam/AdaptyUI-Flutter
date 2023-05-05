import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:adapty_ui_flutter/adapty_ui_flutter.dart';
import 'package:adapty_ui_flutter_example/list_components.dart';
import 'package:flutter/cupertino.dart';

class PaywallsList extends StatefulWidget {
  const PaywallsList({super.key});

  @override
  State<PaywallsList> createState() => _PaywallsListState();
}

class PaywallsListItem {
  String id;
  AdaptyPaywall? paywall;
  AdaptyUIView? view;
  AdaptyError? error;

  PaywallsListItem({required this.id, this.paywall, this.view, this.error});
}

class _PaywallsListState extends State<PaywallsList> {
  final List<String> _paywallsIds = ["london"];
  final Map<String, PaywallsListItem> _paywallsItems = {};

  @override
  void initState() {
    _loadPaywalls();

    super.initState();
  }

  Future<void> _loadPaywallData(String id) async {
    try {
      final paywall = await Adapty().getPaywall(id: id);
      _paywallsItems[id] = PaywallsListItem(id: id, paywall: paywall);

      setState(() {});
    } on AdaptyError catch (adaptyError) {
      _paywallsItems[id] = PaywallsListItem(id: id, error: adaptyError);
    } catch (e) {}
  }

  void _loadPaywalls() {
    for (var id in _paywallsIds) {
      _paywallsItems[id] = PaywallsListItem(id: id);
      setState(() {});
      _loadPaywallData(id);
    }
  }

  Future<void> _createAndPresentPaywallView(AdaptyPaywall paywall) async {
    try {
      final view = await AdaptyUI().createPaywallView(paywall: paywall);
      await AdaptyUI().presentPaywallView(view);
    } on AdaptyError catch (adaptyError) {
      print('error');
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: _paywallsIds.map((paywallId) {
          final item = _paywallsItems[paywallId];

          return ListSection(
            headerText: 'Paywall $paywallId',
            children: item?.paywall == null
                ? const [
                    ListTextTile(
                      title: 'Status',
                      subtitle: 'Error',
                      subtitleColor: CupertinoColors.systemRed,
                    ),
                  ]
                : [
                    const ListTextTile(
                      title: 'Status',
                      subtitle: 'OK',
                      subtitleColor: CupertinoColors.systemGreen,
                    ),
                    ListTextTile(
                      title: 'Variation Id',
                      subtitle: item?.paywall?.variationId,
                      // subtitleColor: CupertinoColors.systemGreen,
                    ),
                    ListActionTile(
                      title: 'Present',
                      onTap: () => _createAndPresentPaywallView(item!.paywall!),
                    ),
                  ],
          );
        }).toList(),
      ),
    );
  }
}
