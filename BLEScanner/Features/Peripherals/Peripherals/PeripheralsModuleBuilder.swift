//
//  PeripheralsModuleBuilder.swift
//  Peripherals
//
//  Created Sameh Mabrouk on 05/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit
import Core

public protocol PeripheralsModuleBuildable: ModuleBuildable {}

public class PeripheralsModuleBuilder:  Builder<EmptyDependency>, PeripheralsModuleBuildable {
    
    public func buildModule<T: Any>(with window: UIWindow) -> Module<T>? {
        registerUsecase()
        registerViewModel()
        registerView()
        registerCoordinator(window: window)
        
        guard let coordinator = container.resolve(PeripheralsCoordinator.self) else {
            return nil
        }
        
        return Module(coordinator: coordinator) as? Module<T>
    }
}

private extension PeripheralsModuleBuilder {
    
    func registerUsecase() {
        container.register(PeripheralsInteractable.self) {
            return PeripheralsUseCase()
        }
    }
    
    func registerViewModel() {
        container.register(PeripheralsViewModel.self) { [weak self] in
            guard let useCase = self?.container.resolve(PeripheralsInteractable.self) else { return nil }
            
            return PeripheralsViewModel(useCase: useCase)
        }
    }
    
    func registerView() {
        container.register(PeripheralsViewController.self) { [weak self] in
            guard let viewModel = self?.container.resolve(PeripheralsViewModel.self) else {
                return nil
            }
            
            return PeripheralsViewController.instantiate(with: viewModel)
        }
    }
    
    func registerCoordinator(window: UIWindow) {
        container.register(PeripheralsCoordinator.self) { [weak self] in
            guard let viewController = self?.container.resolve(PeripheralsViewController.self) else {
                return nil
            }
            
            let coordinator = PeripheralsCoordinator(window: window, viewController: viewController)
            return coordinator
        }
    }
}
