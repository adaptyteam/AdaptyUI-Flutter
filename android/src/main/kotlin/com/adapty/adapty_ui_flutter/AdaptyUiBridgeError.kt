package com.adapty.adapty_ui_flutter

import com.adapty.errors.AdaptyErrorCode

internal sealed class AdaptyUiBridgeError(
    val errorCode: AdaptyErrorCode = AdaptyErrorCode.WRONG_PARAMETER,
    val message: String,
) {
    class ViewNotFound(viewId: String) :
        AdaptyUiBridgeError(message = "AdaptyUIError.viewNotFound($viewId)")

    class ViewAlreadyPresented(viewId: String) :
        AdaptyUiBridgeError(message = "AdaptyUIError.viewAlreadyPresented($viewId)")

    class ViewPresentationError(viewId: String) :
        AdaptyUiBridgeError(message = "AdaptyUIError.viewPresentationError($viewId)")
}
