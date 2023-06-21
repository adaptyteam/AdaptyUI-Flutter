package com.adapty.adapty_ui_flutter

import android.content.SharedPreferences
import com.adapty.internal.crossplatform.CrossplatformHelper
import com.adapty.ui.AdaptyPaywallView
import com.adapty.adapty_ui_flutter.AdaptyUiFlutterEventListener.Companion.PAYWALL_VIEW_DID_PERFORM_SYSTEM_BACK_ACTION
import com.adapty.adapty_ui_flutter.AdaptyUiFlutterEventListener.Companion.VIEW
import java.lang.ref.WeakReference
import java.util.concurrent.ConcurrentHashMap

internal class PaywallUiManager(
    private val prefs: SharedPreferences,
    private val helper: CrossplatformHelper,
) {
    private val cachedPaywallUiData = ConcurrentHashMap<String, PaywallUiData>()

    fun getData(key: String): PaywallUiData? {
        return cachedPaywallUiData[key] ?: getPersistedData()
            ?.takeIf { data -> data.viewId == key }
            ?.also { data -> putData(data.viewId, data) }
    }

    fun putData(key: String, data: PaywallUiData) {
        cachedPaywallUiData[key] = data
    }

    fun removeData(key: String) {
        cachedPaywallUiData.remove(key)
        clearPersistedData()
    }

    fun hasData(key: String) = cachedPaywallUiData[key] != null

    fun persistData(key: String) {
        cachedPaywallUiData[key]?.let { data ->
            prefs.edit().putString(UI_DATA, helper.toJson(data)).apply()
        }
    }

    private fun clearPersistedData() {
        prefs.edit().remove(UI_DATA).apply()
    }

    var isShown = false

    var uiEventsObserver: ((event: AdaptyUiFlutterEvent) -> Unit)? = null

    fun handleSystemBack(key: String): Boolean {
        val currentData = getData(key) ?: return false

        uiEventsObserver?.let {
            it.invoke(
                AdaptyUiFlutterEvent(
                    PAYWALL_VIEW_DID_PERFORM_SYSTEM_BACK_ACTION,
                    mapOf(VIEW to currentData.jsonView),
                )
            )
            return true
        }
        return false
    }

    private var paywallView: WeakReference<AdaptyPaywallView>? = null

    fun getCurrentView(): AdaptyPaywallView? = paywallView?.get()

    fun setCurrentView(viewId: String, view: AdaptyPaywallView) {
        val currentData = getData(viewId) ?: return

        view.setEventListener(object : AdaptyUiFlutterEventListener(currentData) {
            override fun onEvent(event: AdaptyUiFlutterEvent) {
                uiEventsObserver?.invoke(event)
            }
        })

        paywallView = WeakReference(view)
    }

    fun clearCurrentView() {
        paywallView?.clear()
    }

    private fun getPersistedData(): PaywallUiData? =
        prefs.getString(UI_DATA, null)
            ?.takeIf { it.isNotEmpty() }
            ?.let { json -> helper.fromJson(json, PaywallUiData::class.java) }

    private companion object {
        private const val UI_DATA = "UI_DATA"
    }
}