//
//  Module.swift
//  Core
//
//  Created by Sameh Mabrouk on 05/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit

/// A module is Generic type that wraps a coordinator
public struct Module<T> {
    public let coordinator: BaseCoordinator<T>
    
    public init(coordinator: BaseCoordinator<T>) {
        self.coordinator = coordinator
    }
}

public protocol ModuleBuildable: AnyObject {
    func buildModule<T>(with window: UIWindow) -> Module<T>?
    func buildModule<T>(with window: UIWindow, context: Any) -> Module<T>?
    func buildModule<T>(with rootViewController: Presentable) -> Module<T>?
}

extension ModuleBuildable {
    public func buildModule<T>(with window: UIWindow) -> Module<T>? {
        return nil
    }
        
    public func buildModule<T>(with window: UIWindow, context: Any) -> Module<T>? {
        return nil
    }
    
    public func buildModule<T>(with rootViewController: Presentable) -> Module<T>? {
        return nil
    }
}
