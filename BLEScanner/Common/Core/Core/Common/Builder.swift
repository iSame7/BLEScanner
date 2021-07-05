//
//  Builder.swift
//  Core
//
//  Created by Sameh Mabrouk on 05/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

/// A Builder can build new objects using a dependency as input
///
/// Builders can be added to an architecture to simplify dependency
/// injecten and (therefore) object creation.
open class Builder<DependencyType> {
    /// DependencyType instance to use to create return a built instance
    public let dependency: DependencyType
    public let container: DependencyManager

    /// Initialises a new builder instance
    ///
    /// - Parameter dependency: Dependency of type DependencyType
    public init(dependency: DependencyType, container: DependencyManager  = DependencyManager.shared) {
        self.dependency = dependency
        self.container = container
    }
}

// MARK: - Empty Dependency Support
/// Empty Dependency implementation
/// Is used implicitly when defining a Builder with EmptyDependency
/// as DependencyType
private final class EmptyDependencyImpl: EmptyDependency {}

public extension Builder where DependencyType == EmptyDependency {
    convenience init() {
        self.init(dependency: EmptyDependencyImpl())
    }
}
