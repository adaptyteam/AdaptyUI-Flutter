//
//  AdaptyUI+Dialogs.swift
//  adapty_ui_flutter
//
//  Created by Aleksey Goncharov on 12.2.24..
//

import UIKit

struct AdaptyUIDialogConfiguration: Codable {
    struct Action: Codable {
        enum Style: String, Codable {
            case standard
            case cancel
            case destructive
        }

        let title: String?
        let style: Style
    }

    let title: String?
    let message: String?
    let actions: [Action]?
}

extension AdaptyUIDialogConfiguration.Action.Style {
    var uiAlertActionStyle: UIAlertAction.Style {
        switch self {
        case .standard: return .default
        case .cancel: return .cancel
        case .destructive: return .destructive
        }
    }
}

extension UIAlertController {
    static func create(_ configuration: AdaptyUIDialogConfiguration,
                       handler: @escaping (Int) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: configuration.title,
                                      message: configuration.message,
                                      preferredStyle: .alert)

        if let actions = configuration.actions, !actions.isEmpty {
            for idx in 0 ..< actions.count {
                let action = actions[idx]

                alert.addAction(
                    .init(title: action.title,
                          style: action.style.uiAlertActionStyle) { _ in
                        handler(idx)
                    }
                )
            }
        }

        return alert
    }
}

extension UIViewController {
    func showDialog(_ configuration: AdaptyUIDialogConfiguration,
                    presentationCompletion: @escaping () -> Void,
                    handler: @escaping (Int) -> Void) {
        let alert = UIAlertController.create(configuration, handler: handler)
        present(alert, animated: true, completion: presentationCompletion)
    }
}
