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
  AdaptyError? error;

  PaywallsListItem({required this.id, this.paywall, this.error});
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
      _paywallsItems[id] = PaywallsListItem(id: id, paywall: await Adapty().getPaywall(id: id));

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

  Future<void> _createAndPresentPaywallView(AdaptyPaywall paywall, bool loadProducts) async {
    try {
      List<AdaptyPaywallProduct>? products;

      if (loadProducts) {
        products = await Adapty().getPaywallProducts(paywall: paywall);
      }

      final view = await AdaptyUI().createPaywallView(paywall: paywall, products: products);
      await view.present();
    } on AdaptyError catch (adaptyError) {
      print('error');
    } catch (e) {
      print('error');
    }
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
                      onTap: () => _createAndPresentPaywallView(item!.paywall!, false),
                    ),
                    ListActionTile(
                      title: 'Load Products and Present',
                      onTap: () => _createAndPresentPaywallView(item!.paywall!, true),
                    ),
                  ],
          );
        }).toList(),
      ),
    );
  }
}
