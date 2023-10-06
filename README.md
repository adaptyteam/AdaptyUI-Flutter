<h1 align="center" style="border-bottom: none">
<b>
    <a href="https://adapty.io/?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS">
        <img src="https://adapty-portal-media-production.s3.amazonaws.com/github/logo-adapty-new.svg">
    </a>
</b>
<br>Adapty UI
</h1>

<p align="center">
<a href="https://go.adapty.io/subhub-community-flutter-rep"><img src="https://img.shields.io/badge/Adapty-discord-purple"></a>
<a href="https://github.com/adaptyteam/AdaptySDK-Flutter/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-brightgreen.svg"></a>
</p>

**AdaptyUI** is an open-source framework that is an extension to the Adapty SDK that allows you to easily add purchase screens to your application. It’s 100% open-source, native, and lightweight.

### [1. Fetching Paywalls & ViewConfiguration](https://docs.adapty.io/docs/paywall-builder-fetching)

Paywall can be obtained in the way you are already familiar with:

```dart
import 'package:adapty_flutter/adapty_flutter.dart';

try {
  final paywall = await Adapty().getPaywall(id: paywallId);
} on AdaptyError catch (adaptyError) {
  // handle the error
} catch (e) {
  // handle the error
}
```

After fetching the paywall call the `AdaptyUI.createPaywallView()` method to assembly the view:

```dart
import 'package:adapty_ui_flutter/adapty_ui_flutter.dart';

try {
  final view = await AdaptyUI().createPaywallView(paywall: paywall, locale: 'en');
} on AdaptyError catch (e) {
  // handle the error
} catch (e) {
  // handle the error
}
```

### [2. Presenting Visual Paywalls](https://docs.adapty.io/docs/paywall-builder-presenting)

In order to display the visual paywall on the device screen, you may just simply call `.present()` method of the view, obtained during the previous step:

```dart
try {
  await view.present();
} on AdaptyError catch (e) {
  // handle the error
} catch (e) {
  // handle the error
}
```

### 3. Full Documentation and Next Steps

We recommend that you read the [full documentation](https://docs.adapty.io/docs/paywall-builder-getting-started). If you are not familiar with Adapty, then start [here](https://docs.adapty.io/docs).

## Contributing

- Feel free to open an issue, we check all of them or drop us an email at [support@adapty.io](mailto:support@adapty.io) and tell us everything you want.
- Want to suggest a feature? Just contact us or open an issue in the repo.

## Like AdaptyUI?

So do we! Feel free to star the repo ⭐️⭐️⭐️ and make our developers happy!

## License

AdaptyUI is available under the MIT license. [Click here](https://github.com/adaptyteam/AdaptyUI-Flutter/blob/master/LICENSE) for details.

---
