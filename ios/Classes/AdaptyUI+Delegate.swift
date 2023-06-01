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

class AdaptyUIDelegate: NSObject, AdaptyPaywallControllerDelegate {
    let channel: FlutterMethodChannel

    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    private func invokeMethod(_ methodName: MethodName, arguments: [ArgumentName: Encodable]) {
        do {
            channel.invokeMethod(
                methodName.rawValue,
                arguments: Dictionary(uniqueKeysWithValues: try arguments.map {
                    ($0.rawValue, try encodeModelToString($1))
                })
            )
        } catch {
            AdaptyUI.writeLog(level: .error,
                              message: "Plugin encoding error: \(error.localizedDescription)")
        }
    }

    public func paywallControllerDidPressCloseButton(_ controller: AdaptyPaywallController) {
        invokeMethod(.paywallViewDidPressCloseButton,
                     arguments: [
                         .view: controller.toView(),
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
                                  profile: AdaptyProfile) {
        invokeMethod(.paywallViewDidFinishPurchase,
                     arguments: [
                         .view: controller.toView(),
                         .product: product,
                         .profile: profile,
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
                                  didFailLoadingProductsWith policy: AdaptyProductsFetchPolicy,
                                  error: AdaptyError) -> Bool {
        invokeMethod(.paywallViewDidFailLoadingProducts,
                     arguments: [
                         .view: controller.toView(),
                         .fetchPolicy: policy.JSONValue,
                         .error: error,
                     ])

        return policy == .default
    }
}
