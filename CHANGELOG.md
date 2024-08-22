## 2.1.3
- Support for Flutter 3.22+
- support for Adapty Flutter SDK 2.10.2

## 2.1.2
- support for AdaptyUI iOS 2.1.3 and higher
  
## 2.1.1
- support for Adapty Flutter SDK 2.10.0
  
## 2.1.0
⚠️ Update Adapty Flutter SDK to 2.9.3

- added support for [custom fonts](https://docs.adapty.io/docs/using-custom-fonts-in-paywall-builder)
- added support for [custom tags](https://docs.adapty.io/docs/custom-tags-in-paywall-builder)
- add support for [close button transition](https://docs.adapty.io/docs/paywall-layout-and-products#close-button-its-style-placement-and-fade-in-animation)
- added `paywallViewDidStartRestore` method to `AdaptyUIObserver`
- added `showDialog` method which allows to present native dialog above the paywall screen

## 2.0.6

- [Android] fixed event handling in some circumstances

## 2.0.5

- [Android] fixed rendering and initial product selection in some circumstances

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
