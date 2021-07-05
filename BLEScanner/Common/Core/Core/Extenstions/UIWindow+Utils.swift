//
//  UIWindow+Utils.swift
//  Core
//
//  Created by Sameh Mabrouk on 05/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit

public extension UIWindow {
    func setRootViewController(viewController: UIViewController) {
        rootViewController = viewController
        makeKeyAndVisible()
    }
}
