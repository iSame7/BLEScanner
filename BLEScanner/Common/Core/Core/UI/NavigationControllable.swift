//
//  NavigationControllable.swift
//  Core
//
//  Created by Sameh Mabrouk on 08/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit

public protocol NavigationControllable: AnyObject {
    func pushViewController(_ viewController: UIViewController, animated: Bool)
    func popViewController(animated: Bool) -> UIViewController?
    func popToRootViewController(animated: Bool) -> [UIViewController]?
    func setViewControllers(_ viewControllers: [UIViewController], animated: Bool)
}

extension UINavigationController: NavigationControllable {}
