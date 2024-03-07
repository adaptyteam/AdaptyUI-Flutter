//
//  AdaptyUI+Dialogs.swift
//  adapty_ui_flutter
//
//  Created by Aleksey Goncharov on 12.2.24..
//

import UIKit

struct AdaptyUIDialogConfiguration: Codable {
    struct Action: Codable {
        let title: String?
    }

    let title: String?
    let content: String?
    let defaultAction: Action
    let secondaryAction: Action?

    enum CodingKeys: String, CodingKey {
        case title
        case content
        case defaultAction = "default_action"
        case secondaryAction = "secondary_action"
    }
}

extension UIAlertController {
    static func create(
        _ configuration: AdaptyUIDialogConfiguration,
        defaultActionHandler: @escaping () -> Void,
        secondaryActionHandler: @escaping () -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(title: configuration.title,
                                      message: configuration.content,
                                      preferredStyle: .alert)

        alert.addAction(
            .init(title: configuration.defaultAction.title,
                  style: .cancel) { _ in
                defaultActionHandler()
            }
        )

        if let secondaryAction = configuration.secondaryAction {
            alert.addAction(
                .init(title: secondaryAction.title,
                      style: .default) { _ in
                    secondaryActionHandler()
                }
            )
        }

        return alert
    }
}

extension UIViewController {
    func showDialog(
        _ configuration: AdaptyUIDialogConfiguration,
        defaultActionHandler: @escaping () -> Void,
        secondaryActionHandler: @escaping () -> Void
    ) {
        let alert = UIAlertController.create(configuration,
                                             defaultActionHandler: defaultActionHandler,
                                             secondaryActionHandler: secondaryActionHandler)
        present(alert, animated: true)
    }
}
