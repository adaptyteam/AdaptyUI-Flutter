//
//  AdaptyUI+Delegate.swift
//  adapty_ui_flutter
//
//  Created by Alexey Goncharov on 31.5.23..
//

import Adapty
import AdaptyUI
import Flutter
import Foundation

extension AdaptyUI {
    struct ActionProxy: Codable {
        let type: String
        let value: String?

        init(type: String, value: String?) {
            self.type = type
            self.value = value
        }
    }
}

extension AdaptyUI.Action {
    var codableAction: AdaptyUI.ActionProxy {
        switch self {
        case .close: return AdaptyUI.ActionProxy(type: "close", value: nil)
        case let .openURL(url): return AdaptyUI.ActionProxy(type: "open_url", value: url.absoluteString)
        case let .custom(id): return AdaptyUI.ActionProxy(type: "custom", value: id)
        }
    }
}

class AdaptyUIDelegate: NSObject, AdaptyPaywallControllerDelegate {
    let channel: FlutterMethodChannel

    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    private func invokeMethod(_ methodName: MethodName, arguments: [ArgumentName: Encodable]) {
        do {
            var args = [String: String]()

            for (arg, model) in arguments {
                args[arg.rawValue] = try encodeModelToString(model)
            }

            channel.invokeMethod(methodName.rawValue, arguments: args)
        } catch {
            AdaptyUI.writeLog(level: .error,
                              message: "Plugin encoding error: \(error.localizedDescription)")
        }
    }

    func paywallController(_ controller: AdaptyPaywallController, didPerform action: AdaptyUI.Action) {
        invokeMethod(.paywallViewDidPerformAction,
                     arguments: [
                         .view: controller.toView(),
                         .action: action.codableAction,
                     ])
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didSelectProduct product: AdaptyPaywallProduct) {
        invokeMethod(.paywallViewDidSelectProduct,
                     arguments: [
                         .view: controller.toView(),
                         .product: product,
                     ])
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didStartPurchase product: AdaptyPaywallProduct) {
        invokeMethod(.paywallViewDidStartPurchase,
                     arguments: [
                         .view: controller.toView(),
                         .product: product,
                     ])
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didCancelPurchase product: AdaptyPaywallProduct) {
        invokeMethod(.paywallViewDidCancelPurchase,
                     arguments: [
                         .view: controller.toView(),
                         .product: product,
                     ])
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFinishPurchase product: AdaptyPaywallProduct,
                                  purchasedInfo: AdaptyPurchasedInfo) {
        invokeMethod(.paywallViewDidFinishPurchase,
                     arguments: [
                         .view: controller.toView(),
                         .product: product,
                         .profile: purchasedInfo.profile,
                     ])
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailPurchase product: AdaptyPaywallProduct,
                                  error: AdaptyError) {
        invokeMethod(.paywallViewDidFailPurchase,
                     arguments: [
                         .view: controller.toView(),
                         .product: product,
                         .error: error,
                     ])
    }

    func paywallControllerDidStartRestore(_ controller: AdaptyPaywallController) {
        invokeMethod(.paywallViewDidStartRestore,
                     arguments: [
                         .view: controller.toView(),
                     ])
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFinishRestoreWith profile: AdaptyProfile) {
        invokeMethod(.paywallViewDidFinishRestore,
                     arguments: [
                         .view: controller.toView(),
                         .profile: profile,
                     ])
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailRestoreWith error: AdaptyError) {
        invokeMethod(.paywallViewDidFailRestore,
                     arguments: [
                         .view: controller.toView(),
                         .error: error,
                     ])
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailRenderingWith error: AdaptyError) {
        invokeMethod(.paywallViewDidFailRendering,
                     arguments: [
                         .view: controller.toView(),
                         .error: error,
                     ])
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailLoadingProductsWith error: AdaptyError) -> Bool {
        invokeMethod(.paywallViewDidFailLoadingProducts,
                     arguments: [
                         .view: controller.toView(),
                         .error: error,
                     ])

        return true
    }
}
