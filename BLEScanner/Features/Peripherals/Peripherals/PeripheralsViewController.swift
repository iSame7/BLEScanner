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
        tableView.registerCell(withType: PeripheralCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    
    private lazy var bluetoothDisabledView: BluetoothDisabledView = {
        let view = BluetoothDisabledView(frame: UIScreen.main.bounds)
//        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.inputs.viewState.onNext(.appeared)
    }
    
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
//            bluetoothDisabledView.topAnchor.constraint(equalTo: view.topAnchor),
//            bluetoothDisabledView.leftAnchor.constraint(equalTo: view.leftAnchor),
//            bluetoothDisabledView.rightAnchor.constraint(equalTo: view.rightAnchor),
//            bluetoothDisabledView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func setupSubviews() {
        view.addSubview(tableView)
//        view.addSubview(bluetoothDisabledView)
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(bluetoothDisabledView)
        }
        bluetoothDisabledView.isHidden = true
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
        
        viewModel.outputs.hideErrorView
            .bind(to: bluetoothDisabledView.rx.isHidden)
            .disposed(by: viewModel.disposeBag)
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
        let cell = tableView.getCell(forType: PeripheralCell.self)
        //        cell.textLabel?.text = viewModel.peripherals[indexPath.row].bkPeripheral.name ?? "Unnamed"
        //        let rssi = viewModel.peripherals[indexPath.row].rssi
        
        cell.configure(withPeripheralName: viewModel.peripherals[indexPath.row].bkPeripheral.name ?? "Unnamed", signalStrength: "\(viewModel.peripherals[indexPath.row].rssi)", signalStengthImage: UIImage())
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
