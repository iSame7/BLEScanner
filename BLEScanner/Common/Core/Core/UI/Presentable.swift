//
//  Presentable.swift
//  Core
//
//  Created by Sameh Mabrouk on 03/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit

public protocol Presentable: AnyObject {
    func presentInFullScreen(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
}

extension UIViewController: Presentable {
    
    public func presentInFullScreen(_ viewController: UIViewController,
                             animated: Bool,
                             completion: (() -> Void)? = nil) {
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: animated, completion: completion)
    }
}
