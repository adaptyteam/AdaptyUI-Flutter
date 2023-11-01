## 2.0.4

- [Android] fixed dependencies

## 2.0.3

- [Android] fixed wrong text alignment in some configurations

## 2.0.2

- [iOS] fixed a bug where paywallViewDidFinishPurchase was not being fired

## 2.0.1

- minor internal improvements for better RTL languages support

## 2.0.0

🎉 We are happy to introduce our new version of AdaptyUI SDK! Please, revise our [documentation](https://docs.adapty.io/docs/paywall-builder-installation-flutter).

⚠️ **Breaking Changes**:

- `locale` param introduced for `.createPaywallView()` method.
- `productsTitlesResolver` param of `.createPaywallView()` method was removed. This feature was implemented within dashboard.
- Introducing `AdaptyUIAction`. [Read more.](https://docs.adapty.io/docs/paywall-builder-events-flutter#actions)
- `.paywallViewDidPressCloseButton()` was replaced with `.paywallViewDidPerformAction()`.
- `.paywallViewDidPerformSystemBackActionOnAndroid` was replaced with `.paywallViewDidPerformAction()`.

## 1.1.0

- Initial Release. [Read More.](https://docs.adapty.io/docs/paywall-builder-getting-started)
