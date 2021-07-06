//
//  AppRootCoordinator.swift
//  BLEScanner
//
//  Created by Sameh Mabrouk on 06/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit
import Core
import RxSwift
import Peripherals

class AppRootCoordinator: BaseCoordinator<Void> {
    
    private let window: UIWindow
    private let locationsModuleBuilder: ModuleBuildable
    
    init(window: UIWindow, locationsModuleBuilder: ModuleBuildable) {
        self.window = window
        self.locationsModuleBuilder = locationsModuleBuilder
    }
    
    override func start() -> Observable<Void> {
        guard let locationsCoordinator: BaseCoordinator<Void> = locationsModuleBuilder.buildModule(with: window)?.coordinator else {
            preconditionFailure("[AppCoordinator] Cannot get locationsModuleBuilder from module builder")
        }
        
        _ = coordinate(to: locationsCoordinator).subscribe({ event in
            
        }).disposed(by: disposeBag)
        return .never()
    }
}
