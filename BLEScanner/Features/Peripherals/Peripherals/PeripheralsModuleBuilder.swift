//
//  PeripheralsModuleBuilder.swift
//  Peripherals
//
//  Created Sameh Mabrouk on 05/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit
import Core
import BlueKit
import PeripheralDetails

/// Provides all dependencies to build the PeripheralsModuleBuilder
private final class PeripheralDependencyProvider: DependencyProvider<EmptyDependency> {
    
    fileprivate var peripheralDetailsModuleBuilder: PeripheralDetailsModuleBuildable { PeripheralDetailsModuleBuilder() }
}


public protocol PeripheralsModuleBuildable: ModuleBuildable {}

public class PeripheralsModuleBuilder:  Builder<EmptyDependency>, PeripheralsModuleBuildable {
    
    public func buildModule<T: Any>(with window: UIWindow) -> Module<T>? {
        let peripheralDependencyProvider = PeripheralDependencyProvider()

        registerService()
        registerUsecase()
        registerViewModel()
        registerView()
        registerCoordinator(window: window, peripheralDetailsModuleBuilder: peripheralDependencyProvider.peripheralDetailsModuleBuilder)
        
        guard let coordinator = container.resolve(PeripheralsCoordinator.self) else {
            return nil
        }
        
        return Module(coordinator: coordinator) as? Module<T>
    }
}

private extension PeripheralsModuleBuilder {
    
    func registerService() {
        container.register(BKCentralManaging.self) {
            BKCentral.shared
        }
        
        container.register(BKBluetoothControling.self) {
            BKBluetoothManager.shared
        }
        
        container.register(PeripheralsFetching.self) { [weak self] in
            guard let bkCentral = self?.container.resolve(BKCentralManaging.self),
                  let bluetoothManager = self?.container.resolve(BKBluetoothControling.self) else { return nil }
            
            return PeripheralsService(centralManager: bkCentral, bluetoothManager: bluetoothManager)
        }
    }
    
    func registerUsecase() {
        container.register(PeripheralsInteractable.self) { [weak self] in
            guard let service = self?.container.resolve(PeripheralsFetching.self) else { return nil }
            return PeripheralsUseCase(service: service)
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
    
    func registerCoordinator(window: UIWindow, peripheralDetailsModuleBuilder: PeripheralDetailsModuleBuildable) {
        container.register(PeripheralsCoordinator.self) { [weak self] in
            guard let viewController = self?.container.resolve(PeripheralsViewController.self) else {
                return nil
            }
            
            let coordinator = PeripheralsCoordinator(window: window, viewController: UINavigationController(rootViewController: viewController), peripheralDetailsModuleBuilder: peripheralDetailsModuleBuilder)
            coordinator.showPeripheralDetials = viewController.viewModel.outputs.showPeripheralDetails
            return coordinator
        }
    }
}
