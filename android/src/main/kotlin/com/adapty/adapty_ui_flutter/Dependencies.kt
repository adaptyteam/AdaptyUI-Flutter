package com.adapty.adapty_ui_flutter

import android.content.Context
import android.content.SharedPreferences
import com.adapty.internal.crossplatform.CrossplatformHelper
import com.adapty.internal.crossplatform.CrossplatformName.FLUTTER
import com.adapty.internal.crossplatform.MetaInfo
import kotlin.LazyThreadSafetyMode.NONE

internal object Dependencies {
    internal inline fun <reified T> inject(named: String? = null) = lazy(NONE) {
        injectInternal<T>(named)
    }

    private inline fun <reified T> injectInternal(named: String? = null) =
        (map[T::class.java]!![named] as DIObject<T>).provide()

    @get:JvmSynthetic
    internal val map = hashMapOf<Class<*>, Map<String?, DIObject<*>>>()

    private fun <T> singleVariantDiObject(
        initializer: () -> T,
        initType: DIObject.InitType = DIObject.InitType.SINGLETON
    ): Map<String?, DIObject<T>> = mapOf(null to DIObject(initializer, initType))

    @JvmSynthetic
    internal fun init(appContext: Context) {
        map.putAll(
            listOf(
                SharedPreferences::class.java to singleVariantDiObject({
                    appContext.getSharedPreferences("AdaptySDKPrefs", Context.MODE_PRIVATE)
                }),

                PaywallUiManager::class.java to singleVariantDiObject({
                    PaywallUiManager(injectInternal(), injectInternal())
                }),

                CrossplatformHelper::class.java to singleVariantDiObject({
                    CrossplatformHelper.shared
                }),

                AdaptyUiCallHandler::class.java to singleVariantDiObject({
                    AdaptyUiCallHandler(injectInternal(), injectInternal())
                }),
            )
        )
    }
}