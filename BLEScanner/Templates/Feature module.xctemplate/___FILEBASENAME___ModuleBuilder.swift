//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import Utils
import Components
import Core

protocol ___VARIABLE_productName:identifier___ModuleBuildable: ModuleBuildable {}

class ___VARIABLE_productName:identifier___ModuleBuilder: ___VARIABLE_productName:identifier___ModuleBuildable {
    
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
        
        guard let coordinator = container.resolve(___VARIABLE_productName:identifier___Coordinator.self) else {
            return nil
        }
        
        return Module(coordinator: coordinator) as? Module<T>
    }
}

private extension ___VARIABLE_productName:identifier___ModuleBuilder {
    
    func registerUsecase() {
        container.register(___VARIABLE_productName:identifier___Interactable.self) { [weak self] in
            guard let self = self,
                let service = self.container.resolve(___VARIABLE_productName:identifier___ServicePerforming.self) else { return nil }
            return ___VARIABLE_productName:identifier___UseCase(service: service)
        }
    }
    
    func registerService() {
        container.register(ServiceErrorListener.self) { TemperServiceErrorListener() }
        container.register(CoreConfiguration.self) { CoreConfiguration.sharedInstance }
        container.register(GraphQLClientProtocol.self) { [weak self] in
            guard let coreConfiguration = self?.container.resolve(CoreConfiguration.self) else { return nil }
            return GraphQLClient(withConfiguration: coreConfiguration)
        }
        
        container.register(___VARIABLE_productName:identifier___ServicePerforming.self) { [weak self] in
            guard let client = self?.container.resolve(GraphQLClientProtocol.self),
                let listener = self?.container.resolve(ServiceErrorListener.self) else { return nil }
            return ___VARIABLE_productName:identifier___Service(client: client, serviceErrorListener: listener)
        }
    }
    
    func registerViewModel() {
        container.register(___VARIABLE_productName:identifier___ViewModel.self) { [weak self] in
            guard let useCase = self?.container.resolve(___VARIABLE_productName:identifier___Interactable.self) else { return nil }
            
            return ___VARIABLE_productName:identifier___ViewModel(useCase: useCase)
        }
    }
    
    func registerView() {
        container.register(___VARIABLE_productName:identifier___ViewController.self) { [weak self] in
            guard let viewModel = self?.container.resolve(___VARIABLE_productName:identifier___ViewModel.self) else {
                return nil
            }
            
            return ___VARIABLE_productName:identifier___ViewController.instantiate(with: viewModel)
        }
    }
    
    func registerCoordinator(rootViewController: NavigationControllable? = nil) {
        container.register(___VARIABLE_productName:identifier___Coordinator.self) { [weak self] in
            guard let viewController = self?.container.resolve(___VARIABLE_productName:identifier___ViewController.self) else {
                return nil
            }
            
            let coordinator = ___VARIABLE_productName:identifier___Coordinator(rootViewController: rootViewController, viewController: viewController)
            return coordinator
        }
    }
}
