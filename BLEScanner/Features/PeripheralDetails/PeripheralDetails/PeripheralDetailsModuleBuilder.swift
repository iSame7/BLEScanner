//
//  PeripheralDetailsModuleBuilder.swift
//  PeripheralDetails
//
//  Created Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import Core

public protocol PeripheralDetailsModuleBuildable: ModuleBuildable {
    func buildModule<T>(with rootViewController: NavigationControllable, peripheral: Peripheral) -> Module<T>?
}

public class PeripheralDetailsModuleBuilder: Builder<EmptyDependency>, PeripheralDetailsModuleBuildable {
    
    public func buildModule<T>(with rootViewController: NavigationControllable, peripheral: Peripheral) -> Module<T>? {
        registerService()
        registerUsecase()
        registerViewModel()
        registerView()
        registerCoordinator(rootViewController: rootViewController)
        
        guard let coordinator = container.resolve(PeripheralDetailsCoordinator.self) else {
            return nil
        }
        
        return Module(coordinator: coordinator) as? Module<T>
    }
}

private extension PeripheralDetailsModuleBuilder {
    
    func registerUsecase() {
        container.register(PeripheralDetailsInteractable.self) { [weak self] in
            guard let self = self,
                let service = self.container.resolve(PeripheralDetailsServicePerforming.self) else { return nil }
            return PeripheralDetailsUseCase(service: service)
        }
    }
    
    func registerService() {
        container.register(PeripheralDetailsServicePerforming.self) {
            return PeripheralDetailsService()
        }
    }
    
    func registerViewModel() {
        container.register(PeripheralDetailsViewModel.self) { [weak self] in
            guard let useCase = self?.container.resolve(PeripheralDetailsInteractable.self) else { return nil }
            
            return PeripheralDetailsViewModel(useCase: useCase)
        }
    }
    
    func registerView() {
        container.register(PeripheralDetailsViewController.self) { [weak self] in
            guard let viewModel = self?.container.resolve(PeripheralDetailsViewModel.self) else {
                return nil
            }
            
            return PeripheralDetailsViewController.instantiate(with: viewModel)
        }
    }
    
    func registerCoordinator(rootViewController: NavigationControllable? = nil) {
        container.register(PeripheralDetailsCoordinator.self) { [weak self] in
            guard let viewController = self?.container.resolve(PeripheralDetailsViewController.self) else {
                return nil
            }
            
            let coordinator = PeripheralDetailsCoordinator(rootViewController: rootViewController, viewController: viewController)
            return coordinator
        }
    }
}
