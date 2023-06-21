package com.adapty.adapty_ui_flutter

internal class DIObject<T>(
    private val initializer: () -> T,
    private val initType: InitType = InitType.SINGLETON
) {
    private var cachedObject: T? = null

    @JvmSynthetic
    fun provide(): T {
        return when (initType) {
            InitType.NEW -> {
                initializer()
            }
            else -> {
                cachedObject ?: initializer().also { cachedObject = it }
            }
        }
    }

    internal enum class InitType {
        NEW, SINGLETON
    }
}