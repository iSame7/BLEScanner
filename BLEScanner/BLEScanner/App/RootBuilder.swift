//
//  RootBuilder.swift
//  BLEScanner
//
//  Created by Sameh Mabrouk on 06/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import Core
import Peripherals
import UIKit

/// Provides all dependencies to build the AppRootCoordinator
private final class RootDependencyProvider: DependencyProvider<EmptyDependency> {
        
    fileprivate var peripheralsModuleBuilder: PeripheralsModuleBuildable {
        PeripheralsModuleBuilder()
    }
}

protocol RootBuildable: ModuleBuildable {}

final class RootBuilder: Builder<EmptyDependency>, RootBuildable {
    
    // MARK: - RootBuildable
    
    func buildModule<T>(with window: UIWindow) -> Module<T>? {
        let dependencyProvider = RootDependencyProvider()
        let appRootCoordinator = AppRootCoordinator(window: window, peripheralsModuleBuilder: dependencyProvider.peripheralsModuleBuilder)
        
        return Module(coordinator: appRootCoordinator) as? Module<T>
    }
}
