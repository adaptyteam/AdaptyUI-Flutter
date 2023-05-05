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

    private var paywallControllers = [UUID: AdaptyPaywallController]()

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

    private func cachePaywallController(_ controller: AdaptyPaywallController, id: UUID) {
        paywallControllers[id] = controller
    }

    private func cachedPaywallController(_ id: String) -> AdaptyPaywallController? {
        guard let uuid = UUID(uuidString: id) else { return nil }
        return paywallControllers[uuid]
    }

    private func handleCreateView(_ flutterCall: FlutterMethodCall,
                                  _ flutterResult: @escaping FlutterResult,
                                  _ args: [String: Any]) {
        guard let paywallString = args[SwiftAdaptyUiFlutterConstants.paywall] as? String,
              let paywallData = paywallString.data(using: .utf8),
              let paywall = try? Self.jsonDecoder.decode(AdaptyPaywall.self, from: paywallData) else {
            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyUiFlutterConstants.paywall)
            return
        }

        AdaptyUI.getViewConfiguration(forPaywall: paywall) { [weak self] result in
            switch result {
            case let .success(config):
                let vc = AdaptyUI.paywallController(for: paywall,
                                                    viewConfiguration: config,
                                                    delegate: Self.pluginInstance)

                self?.cachePaywallController(vc, id: vc.id)

                flutterCall.callResult(
                    resultModel: vc.adaptyUIViewModel,
                    result: flutterResult
                )
            case let .failure(error):
                flutterCall.callAdaptyError(flutterResult, error: error)
            }
        }
    }

    private func handlePresentView(_ flutterCall: FlutterMethodCall,
                                   _ flutterResult: @escaping FlutterResult,
                                   _ args: [String: Any]) {
        guard let id = args[SwiftAdaptyUiFlutterConstants.id] as? String,
              let vc = cachedPaywallController(id) else {
            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyUiFlutterConstants.id)
            return
        }

        vc.modalPresentationStyle = .fullScreen

        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            rootVC.present(vc, animated: true)
        }
    }

    private func handleDismissView(_ flutterCall: FlutterMethodCall,
                                   _ flutterResult: @escaping FlutterResult,
                                   _ args: [String: Any]) {
        guard let id = args[SwiftAdaptyUiFlutterConstants.id] as? String,
              let vc = cachedPaywallController(id) else {
            flutterCall.callParameterError(flutterResult, parameter: SwiftAdaptyUiFlutterConstants.id)
            return
        }

        vc.dismiss(animated: true)
    }
}

extension SwiftAdaptyUiFlutterPlugin: AdaptyPaywallControllerDelegate {
    public func paywallControllerDidPressCloseButton(_ controller: AdaptyPaywallController) {
        do {
            Self.channel?.invokeMethod(
                MethodName.paywallViewDidPressCloseButton.rawValue,
                arguments: [
                    ArgumentName.view.rawValue: try encodeModelToString(controller.adaptyUIViewModel),
                ]
            )
        } catch {
            Adapty.writeLog(level: .error,
                            message: "Plugin encoding error: \(error.localizedDescription)")
        }
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didSelectProduct product: AdaptyPaywallProduct) {
        do {
            Self.channel?.invokeMethod(
                MethodName.paywallViewDidSelectProduct.rawValue,
                arguments: [
                    ArgumentName.view.rawValue: try encodeModelToString(controller.adaptyUIViewModel),
                    ArgumentName.product.rawValue: try encodeModelToString(product),
                ]
            )
        } catch {
            Adapty.writeLog(level: .error,
                            message: "Plugin encoding error: \(error.localizedDescription)")
        }
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didStartPurchase product: AdaptyPaywallProduct) {
        do {
            Self.channel?.invokeMethod(
                MethodName.paywallViewDidStartPurchase.rawValue,
                arguments: [
                    ArgumentName.view.rawValue: try encodeModelToString(controller.adaptyUIViewModel),
                    ArgumentName.product.rawValue: try encodeModelToString(product),
                ]
            )
        } catch {
            Adapty.writeLog(level: .error,
                            message: "Plugin encoding error: \(error.localizedDescription)")
        }
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didCancelPurchase product: AdaptyPaywallProduct) {
        do {
            Self.channel?.invokeMethod(
                MethodName.paywallViewDidCancelPurchase.rawValue,
                arguments: [
                    ArgumentName.view.rawValue: try encodeModelToString(controller.adaptyUIViewModel),
                    ArgumentName.product.rawValue: try encodeModelToString(product),
                ]
            )
        } catch {
            Adapty.writeLog(level: .error,
                            message: "Plugin encoding error: \(error.localizedDescription)")
        }
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFinishPurchase product: AdaptyPaywallProduct,
                                  profile: AdaptyProfile) {
        do {
            Self.channel?.invokeMethod(
                MethodName.paywallViewDidFinishPurchase.rawValue,
                arguments: [
                    ArgumentName.view.rawValue: try encodeModelToString(controller.adaptyUIViewModel),
                    ArgumentName.product.rawValue: try encodeModelToString(product),
                    ArgumentName.profile.rawValue: try encodeModelToString(profile),
                ]
            )
        } catch {
            Adapty.writeLog(level: .error,
                            message: "Plugin encoding error: \(error.localizedDescription)")
        }
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailPurchase product: AdaptyPaywallProduct,
                                  error: AdaptyError) {
        do {
            Self.channel?.invokeMethod(
                MethodName.paywallViewDidFailPurchase.rawValue,
                arguments: [
                    ArgumentName.view.rawValue: try encodeModelToString(controller.adaptyUIViewModel),
                    ArgumentName.product.rawValue: try encodeModelToString(product),
                    ArgumentName.error.rawValue: try encodeModelToString(error),
                ]
            )
        } catch {
            Adapty.writeLog(level: .error,
                            message: "Plugin encoding error: \(error.localizedDescription)")
        }
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFinishRestoreWith profile: AdaptyProfile) {
        do {
            Self.channel?.invokeMethod(
                MethodName.paywallViewDidFinishRestore.rawValue,
                arguments: [
                    ArgumentName.view.rawValue: try encodeModelToString(controller.adaptyUIViewModel),
                    ArgumentName.profile.rawValue: try encodeModelToString(profile),
                ]
            )
        } catch {
            Adapty.writeLog(level: .error,
                            message: "Plugin encoding error: \(error.localizedDescription)")
        }
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailRestoreWith error: AdaptyError) {
        do {
            Self.channel?.invokeMethod(
                MethodName.paywallViewDidFailRestore.rawValue,
                arguments: [
                    ArgumentName.view.rawValue: try encodeModelToString(controller.adaptyUIViewModel),
                    ArgumentName.error.rawValue: try encodeModelToString(error),
                ]
            )
        } catch {
            Adapty.writeLog(level: .error,
                            message: "Plugin encoding error: \(error.localizedDescription)")
        }
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailRenderingWith error: AdaptyError) {
        do {
            Self.channel?.invokeMethod(
                MethodName.paywallViewDidFailRendering.rawValue,
                arguments: [
                    ArgumentName.view.rawValue: try encodeModelToString(controller.adaptyUIViewModel),
                    ArgumentName.error.rawValue: try encodeModelToString(error),
                ]
            )
        } catch {
            Adapty.writeLog(level: .error,
                            message: "Plugin encoding error: \(error.localizedDescription)")
        }
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailLoadingProductsWith policy: AdaptyProductsFetchPolicy,
                                  error: AdaptyError) -> Bool {
        do {
            Self.channel?.invokeMethod(
                MethodName.paywallViewDidFailLoadingProducts.rawValue,
                arguments: [
                    ArgumentName.view.rawValue: try encodeModelToString(controller.adaptyUIViewModel),
                    ArgumentName.fetchPolicy.rawValue: policy.JSONValue,
                    ArgumentName.error.rawValue: try encodeModelToString(error),
                ]
            )
        } catch {
            Adapty.writeLog(level: .error,
                            message: "Plugin encoding error: \(error.localizedDescription)")
        }

        return policy == .default
    }
}

enum SwiftAdaptyUiFlutterPluginError: Error {
    case encodeModelError
}

extension AdaptyProductsFetchPolicy {
    var JSONValue: String {
        switch self {
        case .default:
            return "default"
        case .waitForReceiptValidation:
            return "wait_for_receipt_validation"
        }
    }
}

extension SwiftAdaptyUiFlutterPlugin {
    func encodeModelToString<T: Encodable>(_ model: T) throws -> String {
        let resultData = try SwiftAdaptyUiFlutterPlugin.jsonEncoder.encode(model)
        if let result = String(data: resultData, encoding: .utf8) {
            return result
        } else {
            throw SwiftAdaptyUiFlutterPluginError.encodeModelError
        }
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

    static func missingParameter(name: String, method: String, originalError: Error?) -> FlutterError {
        let message = "Error while parsing parameter '\(name)'"
        let detail = "Method: \(method), Parameter: \(name), OriginalError: \(originalError?.localizedDescription ?? "null")"

        return FlutterError(code: adaptyErrorCode,
                            message: message,
                            details: [adaptyErrorCodeKey: AdaptyError.ErrorCode.decodingFailed.rawValue,
                                      adaptyErrorMessageKey: message,
                                      adaptyErrorDetailKey: detail])
    }

    static func encoder(method: String, originalError: Error) -> FlutterError {
        let message = originalError.localizedDescription
        let detail = "Method: \(method))"

        return FlutterError(code: adaptyErrorCode,
                            message: message,
                            details: [adaptyErrorCodeKey: AdaptyError.ErrorCode.encodingFailed.rawValue,
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

extension AdaptyPaywallController {
    var adaptyUIViewModel: [String: String] {
        [
            SwiftAdaptyUiFlutterConstants.id: id.uuidString,
            SwiftAdaptyUiFlutterConstants.templateId: viewConfiguration.templateId,
            SwiftAdaptyUiFlutterConstants.paywallId: paywall.id,
            SwiftAdaptyUiFlutterConstants.paywallVariationId: paywall.variationId,
        ]
    }
}
