//
//  SwiftAdaptyUiFlutterPluginConstants.swift
//  adapty_ui_flutter
//
//  Created by Alexey Goncharov on 27.4.23..
//

import Foundation

struct SwiftAdaptyUiFlutterConstants {
    static let channelName = "flutter.adapty.com/adapty_ui"

    static let id = "id"
    static let paywall = "paywall"
    static let products = "products"

    static let paywallId = "paywall_id"
    static let paywallVariationId = "paywall_variation_id"
    static let templateId = "template_id"
}

enum ArgumentName: String {
    case view = "view"
    case product = "product"
    case profile = "profile"
    case fetchPolicy = "fetch_policy"
    case error = "error"
}

enum MethodName: String {
    case createView = "create_view"
    case presentView = "present_view"
    case dismissView = "dismiss_view"

    case paywallViewDidPressCloseButton = "paywall_view_did_press_close_button"
    case paywallViewDidSelectProduct = "paywall_view_did_select_product"
    case paywallViewDidStartPurchase = "paywall_view_did_start_purchase"
    case paywallViewDidCancelPurchase = "paywall_view_did_cancel_purchase"
    case paywallViewDidFinishPurchase = "paywall_view_did_finish_purchase"
    case paywallViewDidFailPurchase = "paywall_view_did_fail_purchase"
    case paywallViewDidFinishRestore = "paywall_view_did_finish_restore"
    case paywallViewDidFailRestore = "paywall_view_did_fail_restore"
    case paywallViewDidFailRendering = "paywall_view_did_fail_rendering"
    case paywallViewDidFailLoadingProducts = "paywall_view_did_fail_loading_products"

    case notImplemented = "not_implemented"
}
