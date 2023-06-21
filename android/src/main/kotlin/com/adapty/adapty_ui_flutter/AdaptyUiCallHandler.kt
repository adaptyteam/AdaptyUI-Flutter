@file:OptIn(InternalAdaptyApi::class)

package com.adapty.adapty_ui_flutter

import android.app.Activity
import android.content.Intent
import com.adapty.Adapty
import com.adapty.errors.AdaptyError
import com.adapty.errors.AdaptyErrorCode
import com.adapty.internal.crossplatform.CrossplatformHelper
import com.adapty.internal.utils.InternalAdaptyApi
import com.adapty.models.AdaptyPaywall
import com.adapty.models.AdaptyPaywallProduct
import com.adapty.models.AdaptyViewConfiguration
import com.adapty.utils.AdaptyResult
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

internal class AdaptyUiCallHandler(
    private val helper: CrossplatformHelper,
    private val paywallUiManager: PaywallUiManager,
) {

    var activity: Activity? = null

    fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            CREATE_VIEW -> handleCreateView(call, result)
            PRESENT_VIEW -> handlePresentView(call, result)
            DISMISS_VIEW -> handleDismissView(call, result)
            else -> result.notImplemented()
        }
    }

    fun handleUiEvents(channel: MethodChannel) {
        paywallUiManager.uiEventsObserver = { event ->
            channel.invokeMethod(
                event.name,
                event.data.mapValues { entry ->
                    if (entry.value is String) entry.value else helper.toJson(entry.value)
                }
            )
        }
    }

    private fun handleCreateView(call: MethodCall, result: MethodChannel.Result) {
        val paywall = parseJsonArgument<AdaptyPaywall>(call, PAYWALL) ?: kotlin.run {
            callParameterError(call, result, PAYWALL)
            return
        }
        val preloadProducts = getArgument(call, PRELOAD_PRODUCTS) ?: false
        val productTitles = getArgument<HashMap<String, String>>(call, PRODUCT_TITLES)

        Adapty.getViewConfiguration(paywall) { viewConfigResult ->
            when (viewConfigResult) {
                is AdaptyResult.Success -> {
                    val viewConfig = viewConfigResult.value

                    if (preloadProducts) {
                        Adapty.getPaywallProducts(paywall) { productsResult ->
                            when (productsResult) {
                                is AdaptyResult.Success -> {
                                    handleCreateViewResult(
                                        result,
                                        paywall,
                                        viewConfig,
                                        productTitles,
                                        productsResult.value,
                                    )
                                }

                                is AdaptyResult.Error -> {
                                    handleCreateViewResult(
                                        result,
                                        paywall,
                                        viewConfig,
                                        productTitles,
                                    )
                                }
                            }
                        }
                    } else {
                        handleCreateViewResult(result, paywall, viewConfig, productTitles)
                    }
                }

                is AdaptyResult.Error -> {
                    handleAdaptyError(result, viewConfigResult.error)
                }
            }
        }
    }

    private fun handleCreateViewResult(
        result: MethodChannel.Result,
        paywall: AdaptyPaywall,
        viewConfig: AdaptyViewConfiguration,
        productTitles: Map<String, String>?,
        products: List<AdaptyPaywallProduct>? = null,
    ) {
        val viewId = UUID.randomUUID().toString()

        val jsonView = helper.toJson(
            mapOf(
                ID to viewId,
                TEMPLATE_ID to viewConfig.templateId,
                PAYWALL_ID to paywall.id,
                PAYWALL_VARIATION_ID to paywall.variationId,
            )
        )

        cachePaywallUiData(
            PaywallUiData(paywall, viewConfig, products, productTitles, viewId, jsonView)
        )

        result.success(jsonView)
    }

    private fun cachePaywallUiData(paywallUiData: PaywallUiData) {
        paywallUiManager.putData(paywallUiData.viewId, paywallUiData)
    }

    private fun clearPaywallUiDataCache(viewId: String) {
        paywallUiManager.removeData(viewId)
    }

    private fun handlePresentView(call: MethodCall, result: MethodChannel.Result) {
        val id = getArgument<String>(call, ID) ?: kotlin.run {
            callParameterError(call, result, ID)
            return
        }

        if (!paywallUiManager.hasData(id)) {
            bridgeError(result, AdaptyUiBridgeError.ViewNotFound(id))
            return
        }

        if (!paywallUiManager.isShown) {
            activity?.let { activity ->
                paywallUiManager.isShown = true
                paywallUiManager.persistData(id)

                activity.runOnUiThread {
                    activity.startActivity(
                        Intent(activity, AdaptyUiActivity::class.java)
                            .putExtra(AdaptyUiActivity.VIEW_ID, id)
                    )
                    activity.overridePendingTransition(
                        R.anim.adapty_ui_slide_up,
                        R.anim.adapty_ui_no_anim
                    )
                    emptyResultOrError(result, null)
                }
            } ?: kotlin.run {
                bridgeError(result, AdaptyUiBridgeError.ViewPresentationError(id))
            }
        } else {
            bridgeError(result, AdaptyUiBridgeError.ViewAlreadyPresented(id))
        }
    }

    private fun handleDismissView(call: MethodCall, result: MethodChannel.Result) {
        val id = getArgument<String>(call, ID) ?: kotlin.run {
            callParameterError(call, result, ID)
            return
        }

        clearPaywallUiDataCache(id)
        (paywallUiManager.getCurrentView()?.context as? AdaptyUiActivity)?.let { activity ->
            activity.runOnUiThread {
                activity.close()
                paywallUiManager.isShown = false
            }
        } ?: kotlin.run {
            bridgeError(result, AdaptyUiBridgeError.ViewNotFound(id))
            return
        }
        emptyResultOrError(result, null)
    }

    private inline fun <reified T : Any> parseJsonArgument(call: MethodCall, paramKey: String): T? {
        return try {
            call.argument<String>(paramKey)?.takeIf(String::isNotEmpty)?.let { json ->
                helper.fromJson(json, T::class.java)
            }
        } catch (e: Exception) {
            null
        }
    }

    private fun <T : Any> getArgument(call: MethodCall, paramKey: String): T? {
        return try {
            call.argument<T>(paramKey)
        } catch (e: Exception) {
            null
        }
    }

    private fun emptyResultOrError(result: MethodChannel.Result, error: AdaptyError?) {
        if (error == null) {
            result.success(null)
        } else {
            handleAdaptyError(result, error)
        }
    }

    private fun handleAdaptyError(result: MethodChannel.Result, error: AdaptyError) {
        result.error(
            ADAPTY_ERROR_CODE,
            error.message,
            helper.toJson(error)
        )
    }

    private fun callParameterError(
        call: MethodCall,
        result: MethodChannel.Result,
        paramKey: String,
        originalError: Throwable? = null
    ) {
        val message = "Error while parsing parameter: $paramKey"
        val detail =
            "Method: ${call.method}, Parameter: $paramKey, OriginalError: ${originalError?.localizedMessage ?: originalError?.message}"
        result.error(
            ADAPTY_ERROR_CODE,
            message,
            mapOf(
                ADAPTY_ERROR_CODE_KEY to AdaptyErrorCode.DECODING_FAILED,
                ADAPTY_ERROR_MESSAGE_KEY to message,
                ADAPTY_ERROR_DETAIL_KEY to detail,
            )
        )
    }

    private fun bridgeError(
        result: MethodChannel.Result,
        bridgeError: AdaptyUiBridgeError,
    ) {
        result.error(
            ADAPTY_ERROR_CODE,
            bridgeError.message,
            mapOf(
                ADAPTY_ERROR_CODE_KEY to bridgeError.errorCode,
                ADAPTY_ERROR_MESSAGE_KEY to bridgeError.message,
            )
        )
    }

    private companion object {
        const val CREATE_VIEW = "create_view"
        const val PRESENT_VIEW = "present_view"
        const val DISMISS_VIEW = "dismiss_view"

        const val ID = "id"
        const val PAYWALL = "paywall"
        const val PRELOAD_PRODUCTS = "preload_products"
        const val PRODUCT_TITLES = "products_titles"
        const val PAYWALL_ID = "paywall_id"
        const val PAYWALL_VARIATION_ID = "paywall_variation_id"
        const val TEMPLATE_ID = "template_id"

        const val ADAPTY_ERROR_CODE = "adapty_flutter_android"
        const val ADAPTY_ERROR_MESSAGE_KEY = "message"
        const val ADAPTY_ERROR_DETAIL_KEY = "detail"
        const val ADAPTY_ERROR_CODE_KEY = "adapty_code"
    }
}