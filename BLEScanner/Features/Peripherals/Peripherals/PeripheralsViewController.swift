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

    // MARK: - Properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.inputs.viewState.onNext(.loaded)
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
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupSubviews() {
        view.addSubview(tableView)
    }
    
    private func setupNavogationBar() {
        title = "Peripherals"
        
        let sort = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortTapped))
        navigationItem.rightBarButtonItem = sort
    }

    override func setupObservers() {
        viewModel.outputs.updatePeripherals.subscribe { [weak self] _ in
            self?.tableView.reloadData()
        }.disposed(by: viewModel.disposeBag)
    }
    
    @IBAction func sortTapped(_ sender: AnyObject) {
        viewModel.inputs.sortPeripherals.onNext(())
    }
}

// MARK: - UITableViewDataSource

extension PeripheralsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = viewModel.peripherals[indexPath.row].bkPeripheral.name ?? "Unnamed"
        return cell
    }
}

// MARK: - UITableViewDataSource

extension PeripheralsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.inputs.itemTapped.onNext(viewModel.peripherals[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
