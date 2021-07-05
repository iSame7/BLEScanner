//
//  PeripheralsViewController.swift
//  Peripherals
//
//  Created Sameh Mabrouk on 05/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit
import Utils

class PeripheralsViewController: UIViewController, ViewModelDependable {

    typealias ViewModel = PeripheralsViewModellable
	var viewModel: ViewModel!

	override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - setupUI

extension PeripheralsViewController {

    func setupUI() {}

    func setupConstraints() {}

    func setupObservers() {}
}
