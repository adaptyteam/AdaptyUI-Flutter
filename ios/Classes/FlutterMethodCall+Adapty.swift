//
//  FlutterMethodCall+Adapty.swift
//  adapty_ui_flutter
//
//  Created by Alexey Goncharov on 31.5.23..
//

import Adapty
import Flutter
import Foundation

extension FlutterMethodCall {
    func callResult<T: Encodable>(resultModel: T, result: @escaping FlutterResult) {
        do {
            let resultData = try jsonEncoder.encode(resultModel)
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
