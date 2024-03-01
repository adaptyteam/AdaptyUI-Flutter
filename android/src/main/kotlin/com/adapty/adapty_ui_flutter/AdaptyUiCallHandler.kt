package com.adapty.adapty_ui_flutter

import android.app.Activity
import com.adapty.errors.AdaptyError
import com.adapty.internal.crossplatform.ui.AdaptyUiBridgeError
import com.adapty.internal.crossplatform.ui.AdaptyUiDialogConfig
import com.adapty.internal.crossplatform.ui.CrossplatformUiHelper
import com.adapty.models.AdaptyPaywall
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal class AdaptyUiCallHandler(
    private val helper: CrossplatformUiHelper,
) {

    private val serialization = helper.serialization

    fun setActivity(activity: Activity?) {
        helper.activity = activity
    }

    fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            CREATE_VIEW -> handleCreateView(call, result)
            PRESENT_VIEW -> handlePresentView(call, result)
            DISMISS_VIEW -> handleDismissView(call, result)
            SHOW_DIALOG -> handleShowDialog(call, result)
            else -> result.notImplemented()
        }
    }

    fun handleUiEvents(channel: MethodChannel) {
        helper.uiEventsObserver = { event ->
            channel.invokeMethod(
                event.name,
                event.data.mapValues { entry ->
                    if (entry.value is String) entry.value else serialization.toJson(entry.value)
                }
            )
        }
    }

    private fun handleCreateView(call: MethodCall, result: MethodChannel.Result) {
        val paywall = parseJsonArgument<AdaptyPaywall>(call, PAYWALL) ?: kotlin.run {
            callParameterError(call, result, PAYWALL)
            return
        }
        val locale = getArgument<String>(call, LOCALE) ?: kotlin.run {
            callParameterError(call, result, LOCALE)
            return
        }
        val preloadProducts = getArgument(call, PRELOAD_PRODUCTS) ?: false
        val personalizedOffers = getArgument<HashMap<String, Boolean>>(call, PERSONALIZED_OFFERS)
        val customTags = getArgument<HashMap<String, String>>(call, CUSTOM_TAGS)

        helper.handleCreateView(
            paywall,
            locale,
            preloadProducts,
            personalizedOffers,
            customTags,
            { view -> result.success(serialization.toJson(view)) },
            { error -> handleAdaptyError(result, error) },
        )
    }

    private fun handlePresentView(call: MethodCall, result: MethodChannel.Result) {
        val id = getArgument<String>(call, ID) ?: kotlin.run {
            callParameterError(call, result, ID)
            return
        }

        helper.handlePresentView(
            id,
            { result.success(null) },
            { error -> bridgeError(result, error) },
        )
    }

    private fun handleDismissView(call: MethodCall, result: MethodChannel.Result) {
        val id = getArgument<String>(call, ID) ?: kotlin.run {
            callParameterError(call, result, ID)
            return
        }

        helper.handleDismissView(
            id,
            { result.success(null) },
            { error -> bridgeError(result, error) },
        )
    }

    private fun handleShowDialog(call: MethodCall, result: MethodChannel.Result) {
        val id = getArgument<String>(call, ID) ?: kotlin.run {
            callParameterError(call, result, ID)
            return
        }

        val configuration = parseJsonArgument<AdaptyUiDialogConfig>(call, CONFIGURATION) ?: kotlin.run {
            callParameterError(call, result, CONFIGURATION)
            return
        }

        helper.handleShowDialog(
            id,
            configuration,
            { action -> result.success(action)},
            { error -> bridgeError(result, error) },
        )
    }

    private inline fun <reified T : Any> parseJsonArgument(call: MethodCall, paramKey: String): T? {
        return try {
            call.argument<String>(paramKey)?.takeIf(String::isNotEmpty)?.let { json ->
                serialization.fromJson(json, T::class.java)
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

    private fun handleAdaptyError(result: MethodChannel.Result, error: AdaptyError) {
        result.error(
            ADAPTY_ERROR_CODE,
            error.message,
            serialization.toJson(error)
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
            serialization.toJson(
                mapOf(
                    ADAPTY_ERROR_CODE_KEY to ADAPTY_ERROR_DECODING_FAILED,
                    ADAPTY_ERROR_MESSAGE_KEY to message,
                    ADAPTY_ERROR_DETAIL_KEY to detail,
                )
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
            serialization.toJson(
                mapOf(
                    ADAPTY_ERROR_CODE_KEY to bridgeError.rawCode,
                    ADAPTY_ERROR_MESSAGE_KEY to bridgeError.message,
                )
            )
        )
    }

    private companion object {
        const val CREATE_VIEW = "create_view"
        const val PRESENT_VIEW = "present_view"
        const val DISMISS_VIEW = "dismiss_view"
        const val SHOW_DIALOG = "show_dialog"

        const val ID = "id"
        const val PAYWALL = "paywall"
        const val LOCALE = "locale"
        const val PRELOAD_PRODUCTS = "preload_products"
        const val PERSONALIZED_OFFERS = "personalized_offers"
        const val CUSTOM_TAGS = "custom_tags"
        const val CONFIGURATION = "configuration"

        const val ADAPTY_ERROR_CODE = "adapty_flutter_android"
        const val ADAPTY_ERROR_MESSAGE_KEY = "message"
        const val ADAPTY_ERROR_DETAIL_KEY = "detail"
        const val ADAPTY_ERROR_CODE_KEY = "adapty_code"

        const val ADAPTY_ERROR_DECODING_FAILED = 2006
    }
}