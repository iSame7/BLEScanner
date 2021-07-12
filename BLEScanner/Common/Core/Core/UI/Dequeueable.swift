//
//  Dequeueable.swift
//  Core
//
//  Created by Sameh Mabrouk on 12/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit

public protocol Dequeueable {
    static var reuseIdentifier: String { get }
}

extension Dequeueable {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

public extension UITableView {
    
    func getCell<T: Dequeueable>(forType type: T.Type) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier) as? T else {
            preconditionFailure("Misconfigured cell type, \(type)!")
        }
        return cell
    }
    
    func registerCell(withType cType: Dequeueable.Type) {
        registerCells(withTypes: [cType])
    }
    
    func registerCells(withTypes types: [Dequeueable.Type]) {
        types.forEach { dequableType in
            if let type = dequableType as? AnyClass {
                register(type, forCellReuseIdentifier: dequableType.reuseIdentifier)
            }
        }
    }
}
