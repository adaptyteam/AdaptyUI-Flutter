package com.adapty.adapty_ui_flutter

import android.app.Activity
import android.os.Bundle
import android.view.View
import androidx.core.graphics.Insets
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.adapty.adapty_ui_flutter.Dependencies.inject
import com.adapty.ui.AdaptyPaywallInsets
import com.adapty.ui.AdaptyPaywallView
import com.adapty.ui.listeners.AdaptyUiProductTitleResolver
import kotlin.LazyThreadSafetyMode.NONE

class AdaptyUiActivity : Activity() {

    internal companion object {
        internal const val VIEW_ID = "VIEW_ID"
    }

    private var paywallInsets = AdaptyPaywallInsets.NONE

    private val paywallView: AdaptyPaywallView by lazy(NONE) {
        AdaptyPaywallView(this)
    }

    private val paywallUiManager: PaywallUiManager by inject()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val viewId = intent?.getStringExtra(VIEW_ID) ?: kotlin.run {
            performBackPress()
            return
        }

        with(paywallView) {
            setContentView(this)
            paywallUiManager.setCurrentView(viewId, this)

            onReceiveSystemBarsInsets { insets ->
                paywallInsets = AdaptyPaywallInsets.of(insets.top, insets.bottom)
                val (paywall, viewConfig, products, productTitles) = paywallUiManager.getData(viewId)
                    ?: kotlin.run {
                        paywallUiManager.removeData(viewId)
                        performBackPress()
                        return@onReceiveSystemBarsInsets
                    }
                showPaywall(
                    paywall,
                    products,
                    viewConfig,
                    paywallInsets,
                    if (productTitles == null) {
                        AdaptyUiProductTitleResolver.DEFAULT
                    } else {
                        AdaptyUiProductTitleResolver { product ->
                            productTitles[product.vendorProductId] ?: product.localizedTitle
                        }
                    }
                )
            }
        }
    }

    fun close() {
        performBackPress()
        overridePendingTransition(R.anim.adapty_ui_no_anim, R.anim.adapty_ui_slide_down)
    }

    override fun onBackPressed() {
        val viewId = intent?.getStringExtra(VIEW_ID) ?: kotlin.run {
            performBackPress()
            return
        }

        if (!paywallUiManager.handleSystemBack(viewId)) {
            performBackPress()
        }
    }

    private fun performBackPress() {
        paywallUiManager.clearCurrentView()
        super.onBackPressed()
    }
}

fun View.onReceiveSystemBarsInsets(action: (insets: Insets) -> Unit) {
    ViewCompat.setOnApplyWindowInsetsListener(this) { _, insets ->
        val systemBarInsets = insets.getInsets(WindowInsetsCompat.Type.systemBars())

        ViewCompat.setOnApplyWindowInsetsListener(this, null)
        action(systemBarInsets)
        insets
    }
}