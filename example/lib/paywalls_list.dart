import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:adapty_ui_flutter/adapty_ui_flutter.dart';
import 'package:adapty_ui_flutter_example/list_components.dart';
import 'package:flutter/cupertino.dart';

typedef OnAdaptyErrorCallback = void Function(AdaptyError error);
typedef OnCustomErrorCallback = void Function(Object error);

class PaywallsList extends StatefulWidget {
  const PaywallsList({super.key, required this.adaptyErrorCallback, required this.customErrorCallback});

  final OnAdaptyErrorCallback adaptyErrorCallback;
  final OnCustomErrorCallback customErrorCallback;

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
    } on AdaptyError catch (e) {
      _paywallsItems[id] = PaywallsListItem(id: id, error: e);

      widget.adaptyErrorCallback(e);
    } catch (e) {
      widget.customErrorCallback(e);
    }
  }

  void _loadPaywalls() {
    for (var id in _paywallsIds) {
      _paywallsItems[id] = PaywallsListItem(id: id);
      setState(() {});
      _loadPaywallData(id);
    }
  }

  bool _loadingPaywall = false;
  bool _loadingPaywallWithProducts = false;

  Future<void> _createAndPresentPaywallView(AdaptyPaywall paywall, bool loadProducts) async {
    setState(() {
      _loadingPaywall = !loadProducts;
      _loadingPaywallWithProducts = loadProducts;
    });

    try {
      final view = await AdaptyUI().createPaywallView(
        paywall: paywall,
        preloadProducts: loadProducts,
        productsTitlesResolver: (productId) {
          return "title_$productId";
        },
      );
      await view.present();
    } on AdaptyError catch (e) {
      widget.adaptyErrorCallback(e);
    } catch (e) {
      widget.customErrorCallback(e);
    } finally {
      setState(() {
        _loadingPaywall = false;
        _loadingPaywallWithProducts = false;
      });
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
                      showProgress: _loadingPaywall,
                      onTap: () => _createAndPresentPaywallView(item!.paywall!, false),
                    ),
                    ListActionTile(
                      title: 'Load Products and Present',
                      showProgress: _loadingPaywallWithProducts,
                      onTap: () => _createAndPresentPaywallView(item!.paywall!, true),
                    ),
                  ],
          );
        }).toList(),
      ),
    );
  }
}
