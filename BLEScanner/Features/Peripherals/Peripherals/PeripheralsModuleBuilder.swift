//
//  PeripheralsModuleBuilder.swift
//  Peripherals
//
//  Created Sameh Mabrouk on 05/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit
import Utils
import Components
import Core

protocol PeripheralsModuleBuildable: ModuleBuildable {}

class PeripheralsModuleBuilder: PeripheralsModuleBuildable {
    
    private let container: DependencyManager
    
    public init(container: DependencyManager) {
        self.container = container
    }
    
    func buildModule<T>(with rootViewController: NavigationControllable) -> Module<T>? {
        registerService()
        registerUsecase()
        registerViewModel()
        registerView()
        registerCoordinator(rootViewController: rootViewController)
        
        guard let coordinator = container.resolve(PeripheralsCoordinator.self) else {
            return nil
        }
        
        return Module(coordinator: coordinator) as? Module<T>
    }
}

private extension PeripheralsModuleBuilder {
    
    func registerUsecase() {
        container.register(PeripheralsInteractable.self) { [weak self] in
            guard let self = self,
                let service = self.container.resolve(PeripheralsServicePerforming.self) else { return nil }
            return PeripheralsUseCase(service: service)
        }
    }
    
    func registerService() {
        container.register(ServiceErrorListener.self) { TemperServiceErrorListener() }
        container.register(CoreConfiguration.self) { CoreConfiguration.sharedInstance }
        container.register(GraphQLClientProtocol.self) { [weak self] in
            guard let coreConfiguration = self?.container.resolve(CoreConfiguration.self) else { return nil }
            return GraphQLClient(withConfiguration: coreConfiguration)
        }
        
        container.register(PeripheralsServicePerforming.self) { [weak self] in
            guard let client = self?.container.resolve(GraphQLClientProtocol.self),
                let listener = self?.container.resolve(ServiceErrorListener.self) else { return nil }
            return PeripheralsService(client: client, serviceErrorListener: listener)
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
    
    func registerCoordinator(rootViewController: NavigationControllable? = nil) {
        container.register(PeripheralsCoordinator.self) { [weak self] in
            guard let viewController = self?.container.resolve(PeripheralsViewController.self) else {
                return nil
            }
            
            let coordinator = PeripheralsCoordinator(rootViewController: rootViewController, viewController: viewController)
            return coordinator
        }
    }
}
