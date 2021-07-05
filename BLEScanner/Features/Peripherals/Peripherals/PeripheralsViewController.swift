//
//  PeripheralsViewController.swift
//  Peripherals
//
//  Created Sameh Mabrouk on 05/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit
import Core

class PeripheralsViewController: ViewController<PeripheralsViewModel> {

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
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = add
        
        title = "Locations"
    }
    
    @objc private func addTapped() {
    }
    
    override func setupObservers() {
    }
}
