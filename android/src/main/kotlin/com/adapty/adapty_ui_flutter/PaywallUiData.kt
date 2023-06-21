package com.adapty.adapty_ui_flutter

import com.adapty.models.AdaptyPaywall
import com.adapty.models.AdaptyPaywallProduct
import com.adapty.models.AdaptyViewConfiguration

internal class PaywallUiData(
    val paywall: AdaptyPaywall,
    val config: AdaptyViewConfiguration,
    val products: List<AdaptyPaywallProduct>?,
    val productTitles: Map<String, String>?,
    val viewId: String,
    val jsonView: String,
) {
    operator fun component1() = paywall

    operator fun component2() = config

    operator fun component3() = products

    operator fun component4() = productTitles
}
