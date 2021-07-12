//
//  Alertable.swift
//  Core
//
//  Created by Sameh Mabrouk on 12/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit.UIViewController

public protocol Alertable {
    func showAlert(title: String, message: String?, cancelActionTitle: String?, continueActionTitle: String?, handler: ((UIAlertAction) -> Void)?)
}

public extension Alertable where Self: UIViewController {
    
    func showAlert(title: String, message: String? = nil, cancelActionTitle: String? = nil, continueActionTitle: String? = nil, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let continueActionTitle = continueActionTitle {
            let continueAction = UIAlertAction(title: continueActionTitle, style: .default, handler: handler)
            alertController.addAction(continueAction)
        }
        
        if let cancelActionTitle = cancelActionTitle {
            let cancelActionTitle = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: handler)
            alertController.addAction(cancelActionTitle)
        }
        
        present(alertController, animated: true, completion: nil)
    }
}
