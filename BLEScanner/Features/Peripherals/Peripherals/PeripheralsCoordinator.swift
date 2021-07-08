//
//  PeripheralsCoordinator.swift
//  Peripherals
//
//  Created Sameh Mabrouk on 05/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import RxSwift
import Core
import PeripheralDetails

class PeripheralsCoordinator: BaseCoordinator<Void> {
    
    private weak var window: UIWindow?
    private let viewController: UINavigationController
    private let peripheralDetailsModuleBuilder: PeripheralDetailsModuleBuildable
        
    var showPeripheralDetials = PublishSubject<(Peripheral)>()

    init(window: UIWindow?, viewController: UINavigationController, peripheralDetailsModuleBuilder: PeripheralDetailsModuleBuildable) {
        self.window = window
        self.viewController = viewController
        self.peripheralDetailsModuleBuilder = peripheralDetailsModuleBuilder
    }
    
    override public func start() -> Observable<Void> {
        window?.setRootViewController(viewController: viewController)

        showPeripheralDetials.subscribe { [weak self] event in
            guard let self = self, let peripheral = event.element else { return }
            
            guard let peripheralDetailsCoordinator: BaseCoordinator<Void> = self.peripheralDetailsModuleBuilder.buildModule(with: self.viewController, peripheral: peripheral)?.coordinator else {
                preconditionFailure("Cannot get venueDetailsCoordinator from module builder")
            }
            
            self.coordinate(to: peripheralDetailsCoordinator).subscribe(onNext: {
            }).disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
        return .never()
    }
}
