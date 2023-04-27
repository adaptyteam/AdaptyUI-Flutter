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
    static let instanceId = "instance_id"
    
    static let paywallId = "paywall_id"
}

enum MethodName: String {
    case createView = "create_view"
    case presentView = "present_view"
    case dismissView = "dismiss_view"

    case notImplemented = "not_implemented"
}
