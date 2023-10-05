//
//  Adapty+Encoding.swift
//  adapty_ui_flutter
//
//  Created by Alexey Goncharov on 31.5.23..
//

import Adapty
import Foundation

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return formatter
}()

let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    decoder.dataDecodingStrategy = .base64
    return decoder
}()

let jsonEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .formatted(dateFormatter)
    encoder.dataEncodingStrategy = .base64
    return encoder
}()

func encodeModelToString<T: Encodable>(_ model: T) throws -> String {
    let resultData = try jsonEncoder.encode(model)
    if let result = String(data: resultData, encoding: .utf8) {
        return result
    } else {
        throw SwiftAdaptyUiFlutterPluginError.encodeModelError
    }
}
