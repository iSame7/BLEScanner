//
//  UIApplication+Uitls.swift
//  Core
//
//  Created by Sameh Mabrouk on 16/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit

public extension UIApplication {
    static var window: UIWindow? {
        if #available(iOS 13, *) {
            return shared.windows.first { $0.isKeyWindow }
        } else {
            return shared.keyWindow
        }
    }
}
