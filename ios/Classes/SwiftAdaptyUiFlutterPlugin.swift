import Adapty
import AdaptyUI

import Flutter
import UIKit

public class SwiftAdaptyUiFlutterPlugin: NSObject, FlutterPlugin {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()

    static var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.dataDecodingStrategy = .base64
        return decoder
    }()

    static var jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        encoder.dataEncodingStrategy = .base64
        return encoder
    }()

    private static var channel: FlutterMethodChannel?
    private static let pluginInstance = SwiftAdaptyUiFlutterPlugin()
    
    private var paywallControllers = [String: AdaptyPaywallController]()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: SwiftAdaptyUiFlutterConstants.channelName,
                                           binaryMessenger: registrar.messenger())

        registrar.addMethodCallDelegate(pluginInstance, channel: channel)

        self.channel = channel
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

    private func handleCreateView(_ flutterCall: FlutterMethodCall,
                                  _ flutterResult: @escaping FlutterResult,
                                  _ args: [String: Any]) {
        guard let paywallId = args[SwiftAdaptyUiFlutterConstants.paywallId] as? String else {
            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyUiFlutterConstants.paywallId)
            return
        }

        Adapty.getPaywall(paywallId) { [weak self] result in
            switch result {
            case let .success(paywall):
                guard paywall.hasViewConfiguration else {
                    flutterCall.callConfigurationError(flutterResult, paywallId: paywall.id)
                    return
                }

                AdaptyUI.getViewConfiguration(forPaywall: paywall) { [weak self] result in
                    switch result {
                    case let .success(config):
                        let vc = AdaptyUI.paywallController(for: paywall,
                                                            viewConfiguration: config,
                                                            delegate: Self.pluginInstance)
                        vc.modalPresentationStyle = .fullScreen
                        
                        let instanceId = UUID().uuidString

                        self?.paywallControllers[instanceId] = vc

                        flutterCall.callResult(resultModel: instanceId, result: flutterResult)
                    case let .failure(error):
                        flutterCall.callAdaptyError(flutterResult, error: error)
                    }
                }

            case let .failure(error):
                flutterCall.callAdaptyError(flutterResult, error: error)
            }
        }
    }

    private func handlePresentView(_ flutterCall: FlutterMethodCall,
                                   _ flutterResult: @escaping FlutterResult,
                                   _ args: [String: Any]) {
        guard let instanceId = args[SwiftAdaptyUiFlutterConstants.instanceId] as? String,
              let vc = paywallControllers[instanceId] else {
            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyUiFlutterConstants.instanceId)
            return
        }
        
        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            rootVC.present(vc, animated: true)
        }
    }

    private func handleDismissView(_ flutterCall: FlutterMethodCall,
                                   _ flutterResult: @escaping FlutterResult,
                                   _ args: [String: Any]) {
        guard let instanceId = args[SwiftAdaptyUiFlutterConstants.instanceId] as? String,
              let vc = paywallControllers[instanceId] else {
            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyUiFlutterConstants.instanceId)
            return
        }
        
        vc.dismiss(animated: true)
    }
}

extension SwiftAdaptyUiFlutterPlugin: AdaptyPaywallControllerDelegate {
    public func paywallControllerDidPressCloseButton(_ controller: AdaptyPaywallController) {
        controller.dismiss(animated: true)
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didSelectProduct product: AdaptyProduct) {
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didStartPurchase product: AdaptyProduct) {
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didCancelPurchase product: AdaptyProduct) {
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFinishPurchase product: AdaptyProduct,
                                  profile: AdaptyProfile) {
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailPurchase product: AdaptyProduct,
                                  error: AdaptyError) {
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFinishRestoreWith profile: AdaptyProfile) {
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailRestoreWith error: AdaptyError) {
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailRenderingWith error: AdaptyError) {
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailLoadingProductsWith policy: AdaptyProductsFetchPolicy,
                                  error: AdaptyError) -> Bool {
        true
    }
}

extension FlutterMethodCall {
    func callResult<T: Encodable>(resultModel: T, result: @escaping FlutterResult) {
        do {
            let resultData = try SwiftAdaptyUiFlutterPlugin.jsonEncoder.encode(resultModel)
            let resultString = String(data: resultData, encoding: .utf8)
            result(resultString)
        } catch {
            result(FlutterError.encoder(method: method, originalError: error))
        }
    }

    func callConfigurationError(_ result: FlutterResult, paywallId: String) {
        result(FlutterError.noViewConfiguration(paywallId: paywallId))
    }

    func callParameterError(_ result: FlutterResult, parameter: String) {
        result(FlutterError.missingParameter(name: parameter, method: method, originalError: nil))
    }

    func callAdaptyError(_ result: FlutterResult, error: AdaptyError?) {
        guard let error = error else {
            result(nil)
            return
        }

        result(FlutterError.fromAdaptyError(error, method: method))
    }
}

extension FlutterError {
    static let adaptyErrorCode = "adapty_flutter_ios"

    static let adaptyErrorMessageKey = "message"
    static let adaptyErrorDetailKey = "detail"
    static let adaptyErrorCodeKey = "adapty_code"

    static func noViewConfiguration(paywallId: String) -> FlutterError {
        let message = "View configuration not found"
        let detail = "The paywall \(paywallId) does not contain view configuration"

        return FlutterError(code: adaptyErrorCode,
                            message: message,
                            details: [adaptyErrorCodeKey: AdaptyError.ErrorCode.badRequest,
                                      adaptyErrorMessageKey: message,
                                      adaptyErrorDetailKey: detail])
    }

    static func missingParameter(name: String, method: String, originalError: Error?) -> FlutterError {
        let message = "Error while parsing parameter '\(name)'"
        let detail = "Method: \(method), Parameter: \(name), OriginalError: \(originalError?.localizedDescription ?? "null")"

        return FlutterError(code: adaptyErrorCode,
                            message: message,
                            details: [adaptyErrorCodeKey: AdaptyError.ErrorCode.decodingFailed,
                                      adaptyErrorMessageKey: message,
                                      adaptyErrorDetailKey: detail])
    }

    static func encoder(method: String, originalError: Error) -> FlutterError {
        let message = originalError.localizedDescription
        let detail = "Method: \(method))"

        return FlutterError(code: adaptyErrorCode,
                            message: message,
                            details: [adaptyErrorCodeKey: AdaptyError.ErrorCode.encodingFailed,
                                      adaptyErrorMessageKey: message,
                                      adaptyErrorDetailKey: detail])
    }

    static func fromAdaptyError(_ adaptyError: AdaptyError, method: String) -> FlutterError {
        do {
            let adaptyErrorData = try SwiftAdaptyUiFlutterPlugin.jsonEncoder.encode(adaptyError)
            let adaptyErrorString = String(data: adaptyErrorData, encoding: .utf8)

            return FlutterError(code: adaptyErrorCode,
                                message: adaptyError.localizedDescription,
                                details: adaptyErrorString)
        } catch {
            return .encoder(method: method, originalError: error)
        }
    }
}
