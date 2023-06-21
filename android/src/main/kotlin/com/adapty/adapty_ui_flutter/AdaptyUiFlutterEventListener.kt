package com.adapty.adapty_ui_flutter

import com.adapty.errors.AdaptyError
import com.adapty.models.AdaptyPaywallProduct
import com.adapty.models.AdaptyProfile
import com.adapty.ui.AdaptyPaywallView
import com.adapty.ui.listeners.AdaptyUiDefaultEventListener
import java.util.concurrent.atomic.AtomicInteger

internal abstract class AdaptyUiFlutterEventListener(
    private val currentData: PaywallUiData,
) : AdaptyUiDefaultEventListener() {

    private val retryCounter = AtomicInteger()

    override fun onCloseButtonClick(view: AdaptyPaywallView) {
        onEvent(
            AdaptyUiFlutterEvent(
                PAYWALL_VIEW_DID_PRESS_CLOSE_BUTTON,
                mapOf(VIEW to currentData.jsonView),
            )
        )
    }

    override fun onProductSelected(product: AdaptyPaywallProduct, view: AdaptyPaywallView) {
        onEvent(
            AdaptyUiFlutterEvent(
                PAYWALL_VIEW_DID_SELECT_PRODUCTS,
                mapOf(VIEW to currentData.jsonView, PRODUCT to product),
            )
        )
    }

    override fun onPurchaseCanceled(product: AdaptyPaywallProduct, view: AdaptyPaywallView) {
        onEvent(
            AdaptyUiFlutterEvent(
                PAYWALL_VIEW_DID_CANCEL_PURCHASE,
                mapOf(VIEW to currentData.jsonView, PRODUCT to product),
            )
        )
    }

    override fun onPurchaseFailure(
        error: AdaptyError,
        product: AdaptyPaywallProduct,
        view: AdaptyPaywallView,
    ) {
        onEvent(
            AdaptyUiFlutterEvent(
                PAYWALL_VIEW_DID_FAIL_PURCHASE,
                mapOf(VIEW to currentData.jsonView, PRODUCT to product, ERROR to error),
            )
        )
    }

    override fun onPurchaseStarted(product: AdaptyPaywallProduct, view: AdaptyPaywallView) {
        onEvent(
            AdaptyUiFlutterEvent(
                PAYWALL_VIEW_DID_START_PURCHASE,
                mapOf(VIEW to currentData.jsonView, PRODUCT to product),
            )
        )
    }

    override fun onPurchaseSuccess(
        profile: AdaptyProfile?,
        product: AdaptyPaywallProduct,
        view: AdaptyPaywallView
    ) {
        onEvent(
            AdaptyUiFlutterEvent(
                PAYWALL_VIEW_DID_FINISH_PURCHASE,
                mutableMapOf(VIEW to currentData.jsonView, PRODUCT to product).apply {
                    profile?.let { profile -> put(PROFILE, profile) }
                },
            )
        )
    }

    override fun onLoadingProductsFailure(error: AdaptyError, view: AdaptyPaywallView): Boolean {
        onEvent(
            AdaptyUiFlutterEvent(
                PAYWALL_VIEW_DID_FAIL_LOADING_PRODUCTS,
                mapOf(VIEW to currentData.jsonView, ERROR to error),
            )
        )
        return retryCounter.incrementAndGet() <= 3
    }

    override fun onRenderingError(error: AdaptyError, view: AdaptyPaywallView) {
        onEvent(
            AdaptyUiFlutterEvent(
                PAYWALL_VIEW_DID_FAIL_RENDERING,
                mapOf(VIEW to currentData.jsonView, ERROR to error),
            )
        )
    }

    override fun onRestoreFailure(error: AdaptyError, view: AdaptyPaywallView) {
        onEvent(
            AdaptyUiFlutterEvent(
                PAYWALL_VIEW_DID_FAIL_RESTORE,
                mapOf(VIEW to currentData.jsonView, ERROR to error),
            )
        )
    }

    override fun onRestoreSuccess(profile: AdaptyProfile, view: AdaptyPaywallView) {
        onEvent(
            AdaptyUiFlutterEvent(
                PAYWALL_VIEW_DID_FINISH_RESTORE,
                mapOf(VIEW to currentData.jsonView, PROFILE to profile),
            )
        )
    }

    abstract fun onEvent(event: AdaptyUiFlutterEvent)

    internal companion object {
        const val VIEW = "view"
        const val PRODUCT = "product"
        const val PROFILE = "profile"
        const val ERROR = "error"

        const val PAYWALL_VIEW_DID_PRESS_CLOSE_BUTTON = "paywall_view_did_press_close_button"
        const val PAYWALL_VIEW_DID_PERFORM_SYSTEM_BACK_ACTION = "paywall_view_did_perform_system_back_action"
        const val PAYWALL_VIEW_DID_SELECT_PRODUCTS = "paywall_view_did_select_product"
        const val PAYWALL_VIEW_DID_START_PURCHASE = "paywall_view_did_start_purchase"
        const val PAYWALL_VIEW_DID_CANCEL_PURCHASE = "paywall_view_did_cancel_purchase"
        const val PAYWALL_VIEW_DID_FINISH_PURCHASE = "paywall_view_did_finish_purchase"
        const val PAYWALL_VIEW_DID_FAIL_PURCHASE = "paywall_view_did_fail_purchase"
        const val PAYWALL_VIEW_DID_FINISH_RESTORE = "paywall_view_did_finish_restore"
        const val PAYWALL_VIEW_DID_FAIL_RESTORE = "paywall_view_did_fail_restore"
        const val PAYWALL_VIEW_DID_FAIL_RENDERING = "paywall_view_did_fail_rendering"
        const val PAYWALL_VIEW_DID_FAIL_LOADING_PRODUCTS = "paywall_view_did_fail_loading_products"
    }
}