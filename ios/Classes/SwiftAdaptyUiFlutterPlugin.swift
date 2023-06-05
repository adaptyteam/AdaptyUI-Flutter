import Adapty
import AdaptyUI

import Flutter
import UIKit

extension UIViewController {
    var isOrContainsAdaptyController: Bool {
        guard let presentedViewController = presentedViewController else {
            return self is AdaptyPaywallController
        }
        return presentedViewController is AdaptyPaywallController
    }
}

public class SwiftAdaptyUiFlutterPlugin: NSObject, FlutterPlugin {
    private static var channel: FlutterMethodChannel?
    private static let pluginInstance = SwiftAdaptyUiFlutterPlugin()
    private static var adaptyUIDelegate: AdaptyUIDelegate!

    private var paywallControllers = [UUID: AdaptyPaywallController]()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: SwiftAdaptyUiFlutterConstants.channelName,
                                           binaryMessenger: registrar.messenger())

        registrar.addMethodCallDelegate(pluginInstance, channel: channel)

        self.channel = channel
        adaptyUIDelegate = AdaptyUIDelegate(channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [String: Any]()

        switch MethodName(rawValue: call.method) ?? .notImplemented {
        case .createView:
            handleCreateView(call, result, args)
        case .presentView:
            handlePresentView(call, result, args)
        case .dismissView:
            handleDismissView(call, result, args)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func cachePaywallController(_ controller: AdaptyPaywallController, id: UUID) {
        paywallControllers[id] = controller
    }

    private func deleteCachedPaywallController(_ id: String) {
        guard let uuid = UUID(uuidString: id) else { return }
        paywallControllers.removeValue(forKey: uuid)
    }

    private func cachedPaywallController(_ id: String) -> AdaptyPaywallController? {
        guard let uuid = UUID(uuidString: id) else { return nil }
        return paywallControllers[uuid]
    }

    private func createView(paywall: AdaptyPaywall,
                            products: [AdaptyPaywallProduct]?,
                            viewConfiguration: AdaptyUI.ViewConfiguration,
                            productsTitlesResolver: ((AdaptyProduct) -> String)?,
                            flutterCall: FlutterMethodCall,
                            flutterResult: @escaping FlutterResult) {
        let vc = AdaptyUI.paywallController(for: paywall,
                                            products: nil,
                                            viewConfiguration: viewConfiguration,
                                            delegate: Self.adaptyUIDelegate,
                                            productsTitlesResolver: nil)

        cachePaywallController(vc, id: vc.id)

        flutterCall.callResult(
            resultModel: vc.toView(),
            result: flutterResult
        )
    }

    private func preloadProductsAndCreateView(paywall: AdaptyPaywall,
                                              preloadProducts: Bool,
                                              viewConfiguration: AdaptyUI.ViewConfiguration,
                                              productsTitlesResolver: ((AdaptyProduct) -> String)?,
                                              flutterCall: FlutterMethodCall,
                                              flutterResult: @escaping FlutterResult) {
        guard preloadProducts else {
            createView(paywall: paywall,
                       products: nil,
                       viewConfiguration: viewConfiguration,
                       productsTitlesResolver: productsTitlesResolver,
                       flutterCall: flutterCall,
                       flutterResult: flutterResult)
            return
        }

        Adapty.getPaywallProducts(paywall: paywall) { [weak self] result in
            switch result {
            case let .success(products):
                self?.createView(paywall: paywall,
                                 products: products,
                                 viewConfiguration: viewConfiguration,
                                 productsTitlesResolver: productsTitlesResolver,
                                 flutterCall: flutterCall,
                                 flutterResult: flutterResult)
            case .failure:
                // TODO: log error
                self?.createView(paywall: paywall,
                                 products: nil,
                                 viewConfiguration: viewConfiguration,
                                 productsTitlesResolver: productsTitlesResolver,
                                 flutterCall: flutterCall,
                                 flutterResult: flutterResult)
            }
        }
    }

    private func getConfigurationAndCreateView(paywall: AdaptyPaywall,
                                               preloadProducts: Bool,
                                               productsTitlesResolver: ((AdaptyProduct) -> String)?,
                                               flutterCall: FlutterMethodCall,
                                               flutterResult: @escaping FlutterResult) {
        AdaptyUI.getViewConfiguration(forPaywall: paywall) { [weak self] result in
            switch result {
            case let .success(config):
                let vc = AdaptyUI.paywallController(for: paywall,
                                                    products: nil,
                                                    viewConfiguration: config,
                                                    delegate: Self.adaptyUIDelegate,
                                                    productsTitlesResolver: productsTitlesResolver)

                self?.cachePaywallController(vc, id: vc.id)

                flutterCall.callResult(
                    resultModel: vc.toView(),
                    result: flutterResult
                )
            case let .failure(error):
                flutterCall.callAdaptyError(flutterResult, error: error)
            }
        }
    }

    private func handleCreateView(_ flutterCall: FlutterMethodCall,
                                  _ flutterResult: @escaping FlutterResult,
                                  _ args: [String: Any]) {
        guard let paywallString = args[SwiftAdaptyUiFlutterConstants.paywall] as? String,
              let paywallData = paywallString.data(using: .utf8),
              let paywall = try? jsonDecoder.decode(AdaptyPaywall.self, from: paywallData) else {
            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyUiFlutterConstants.paywall)
            return
        }

        let preloadProducts = args[SwiftAdaptyUiFlutterConstants.preloadProducts] as? Bool ?? false
        let productsTitles = args[SwiftAdaptyUiFlutterConstants.productsTitles] as? [String: String]

        getConfigurationAndCreateView(
            paywall: paywall,
            preloadProducts: preloadProducts,
            productsTitlesResolver: { productsTitles?[$0.vendorProductId] ?? $0.localizedTitle },
            flutterCall: flutterCall,
            flutterResult: flutterResult
        )
    }

    private func handlePresentView(_ flutterCall: FlutterMethodCall,
                                   _ flutterResult: @escaping FlutterResult,
                                   _ args: [String: Any]) {
        guard let id = args[SwiftAdaptyUiFlutterConstants.id] as? String else {
            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyUiFlutterConstants.id)
            return
        }

        guard let vc = cachedPaywallController(id) else {
            let error = AdaptyError(AdaptyUIFlutterError.viewNotFound(id))
            flutterCall.callAdaptyError(flutterResult, error: error)
            return
        }

        vc.modalPresentationStyle = .overFullScreen

        guard let rootVC = UIApplication.shared.windows.first?.rootViewController else {
            let error = AdaptyError(AdaptyUIFlutterError.viewPresentationError(id))
            flutterCall.callAdaptyError(flutterResult, error: error)
            return
        }

        guard !rootVC.isOrContainsAdaptyController else {
            let error = AdaptyError(AdaptyUIFlutterError.viewAlreadyPresented(id))
            flutterCall.callAdaptyError(flutterResult, error: error)
            return
        }

        rootVC.present(vc, animated: true) {
            flutterResult(true)
        }
    }

    private func handleDismissView(_ flutterCall: FlutterMethodCall,
                                   _ flutterResult: @escaping FlutterResult,
                                   _ args: [String: Any]) {
        guard let id = args[SwiftAdaptyUiFlutterConstants.id] as? String else {
            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyUiFlutterConstants.id)
            return
        }

        guard let vc = cachedPaywallController(id) else {
            let error = AdaptyError(AdaptyUIFlutterError.viewNotFound(id))
            flutterCall.callAdaptyError(flutterResult, error: error)
            return
        }

        vc.dismiss(animated: true) { [weak self] in
            self?.deleteCachedPaywallController(id)
            flutterResult(true)
        }
    }
}
