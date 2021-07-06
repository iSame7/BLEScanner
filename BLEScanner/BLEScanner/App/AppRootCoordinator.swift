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
    private let peripheralsModuleBuilder: PeripheralsModuleBuildable
    
    init(window: UIWindow, peripheralsModuleBuilder: PeripheralsModuleBuildable) {
        self.window = window
        self.peripheralsModuleBuilder = peripheralsModuleBuilder
    }
    
    override func start() -> Observable<Void> {
        guard let peripheralsModuleBuilder: BaseCoordinator<Void> = peripheralsModuleBuilder.buildModule(with: window)?.coordinator else {
            preconditionFailure("[AppCoordinator] Cannot get peripheralsModuleBuilder from module builder")
        }
        
        _ = coordinate(to: peripheralsModuleBuilder).subscribe({ event in
            
        }).disposed(by: disposeBag)
        return .never()
    }
}
