//
//  DependencyProvider.swift
//  Core
//
//  Created by Sameh Mabrouk on 05/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

/// Provides dependencies to a `Builder`'s build method.
open class DependencyProvider<DependencyType> {
    
    // `dependency` variable represents a parent dependency
    public let dependency: DependencyType

    public init(dependency: DependencyType) {
        self.dependency = dependency
    }
}

// MARK: - Empty Dependency Support if no parent dependencies are needed
private final class EmptyDependencyImpl: EmptyDependency {}

public extension DependencyProvider where DependencyType == EmptyDependency {
    convenience init() {
        self.init(dependency: EmptyDependencyImpl())
    }
}
