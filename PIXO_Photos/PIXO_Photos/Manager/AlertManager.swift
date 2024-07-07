//
//  AlertManager.swift
//  PIXO_Photos
//
//  Created by J_Min on 7/7/24.
//

import UIKit

protocol AlertManagerAction { }

struct AlertManager {
    let title: String?
    let message: String?
    let style: UIAlertController.Style
    
    var actions: [AlertManagerAction] = []
    
    struct Action: AlertManagerAction {
        var title: String
        var style: UIAlertAction.Style
        var handler: ((UIAlertController) -> Void)? = nil
        
        func createAction(alert: UIAlertController) -> UIAlertAction {
            UIAlertAction(title: title, style: style) { _ in
                handler?(alert)
            }
        }
    }
    
    struct TextField: AlertManagerAction {
        var textField: UITextField
    }
    
    init(
        title: String? = "",
        message: String? = nil,
        style: UIAlertController.Style = .alert
    ) {
        self.title = title
        self.message = message
        self.style = style
    }
    
    private init(alertManager: AlertManager) {
        self.init(
            title: alertManager.title,
            message: alertManager.message,
            style: alertManager.style
        )
        self.actions = alertManager.actions
    }
    
    func clone() -> AlertManager {
        AlertManager(alertManager: self)
    }
    
    func addAction(
        actionTitle: String,
        style: UIAlertAction.Style,
        handler: ((UIAlertController) -> Void)? = nil
    ) -> AlertManager {
        var manager = clone()
        let action = Action(title: actionTitle, style: style, handler: handler)
        
        manager.actions.append(action)
        
        return manager
    }
    
    func addTextField(placeHolder: String) -> AlertManager {
        var manager = clone()
        let tf = TextField(textField: UITextField())
        tf.textField.placeholder = placeHolder
        
        manager.actions.append(tf)
        
        return manager
    }
    
    /// alertStyle == .actionSheet, device == .pad 인 경우 view 꼭 설정해줘야함
    func createAlert(view: UIView? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        actions.forEach {
            if let tf = $0 as? TextField {
                alert.addTextField { atf in
                    atf.placeholder = tf.textField.placeholder
                }
            } else if let action = $0 as? Action {
                alert.addAction(action.createAction(alert: alert))
            }
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad, let view = view {
            if let popOverController = alert.popoverPresentationController {
                popOverController.sourceView = view
                popOverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popOverController.permittedArrowDirections = []
            }
        }
        
        return alert
    }
    
    func present() {
        let alert = createAlert()
        
        UIApplication.topViewController()?.present(alert, animated: true)
    }
}

