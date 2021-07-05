//
//  BaseCoordinator.swift
//  Core
//
//  Created by Sameh Mabrouk on 05/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import RxSwift
import Foundation

/// Base abstract coordinator generic over the return type of the `start` method.
open class BaseCoordinator<ResultType> {

    /// Typealias which will allows to access a ResultType of the Coordainator by `CoordinatorName.CoordinationResult`.
    public typealias CoordinationResult = ResultType

    /// Utility `DisposeBag` used by the subclasses.
    public let disposeBag = DisposeBag()

    /// Unique identifier.
    private let identifier = UUID()

    /// Dictionary of the child coordinators. Every child coordinator should be added
    /// to that dictionary in order to keep it in memory.
    /// Key is an `identifier` of the child coordinator and value is the coordinator itself.
    /// Value type is `Any` because Swift doesn't allow to store generic types in the array.
    public var childCoordinators = [UUID: Any]()

    /// Stores coordinator to the `childCoordinators` dictionary.
    ///
    /// - Parameter coordinator: Child coordinator to store.
    private func store<T>(coordinator: BaseCoordinator<T>) {
        print("Adding child coordinator to \(self): \(coordinator)")
        childCoordinators[coordinator.identifier] = coordinator
        self.printChildCoordinators()
    }

    /// Release coordinator from the `childCoordinators` dictionary.
    ///
    /// - Parameter coordinator: Coordinator to release.
    private func free<T>(coordinator: BaseCoordinator<T>) {
        print("Removing child coordinator to \(self): \(coordinator)")
        childCoordinators[coordinator.identifier] = nil
        self.printChildCoordinators()
    }

    /// 1. Stores coordinator in a dictionary of child coordinators.
    /// 2. Calls method `start()` on that coordinator.
    /// 3. On the `onNext:` of returning observable of method `start()` removes coordinator from the dictionary.
    ///
    /// - Parameter coordinator: Coordinator to start.
    /// - Returns: Result of `start()` method.
    public func coordinate<T>(to coordinator: BaseCoordinator<T>) -> Observable<T> {
        store(coordinator: coordinator)
        return coordinator.start()
            .do(onNext: { [weak self] _ in
                self?.free(coordinator: coordinator)
            }
        )
    }

    public init() {}
    
    /// Starts job of the coordinator.
    ///
    /// - Returns: Result of coordinator job.
    open func start() -> Observable<ResultType> {
        fatalError("Start method should be implemented.")
    }

    /// Print the list of child coordinators. Works on debug mode ONLY
    func printChildCoordinators() {
        print("Child coordinators for \(self): \(childCoordinators.values)")
    }
}
