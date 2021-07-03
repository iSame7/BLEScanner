//
//  ViewControllable.swift
//  Core
//
//  Created by Sameh Mabrouk on 03/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit

public protocol ViewControllable {
    associatedtype ViewModel
    var uiviewController: UIViewController { get }
    var viewModel: ViewModel! { get set }

    func setupUI()
    func setupConstraints()
    func setupObservers()
}

public extension ViewControllable where Self: UIViewController {

    static func instantiate(with viewModel: ViewModel) -> Self {
        var viewController = Self.init()
        viewController.viewModel = viewModel
        return viewController
    }
}
