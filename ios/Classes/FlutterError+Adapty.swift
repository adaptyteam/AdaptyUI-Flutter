//
//  FlutterError+Adapty.swift
//  adapty_ui_flutter
//
//  Created by Alexey Goncharov on 31.5.23..
//

import Adapty
import Flutter
import Foundation

enum SwiftAdaptyUiFlutterPluginError: Error {
    case encodeModelError
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
            let adaptyErrorData = try jsonEncoder.encode(adaptyError)
            let adaptyErrorString = String(data: adaptyErrorData, encoding: .utf8)

            return FlutterError(code: adaptyErrorCode,
                                message: adaptyError.localizedDescription,
                                details: adaptyErrorString)
        } catch {
            return .encoder(method: method, originalError: error)
        }
    }
}
