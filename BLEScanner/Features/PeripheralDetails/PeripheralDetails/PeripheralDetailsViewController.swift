//
//  PeripheralDetailsViewController.swift
//  PeripheralDetails
//
//  Created Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import Core

class PeripheralDetailsViewController: ViewController<PeripheralDetailsViewModel> {

	override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - setupUI
    
    override func setupUI() {
        setupSubviews()
        setupConstraints()
        setupNavogationBar()
        setupObservers()
        
        view.backgroundColor = .white
    }
    
    override func setupConstraints() {
    }
    
    func setupSubviews() {
    }
    
    private func setupNavogationBar() {
        title = "Peripheral Details"
    }

    override func setupObservers() {
    }
}
