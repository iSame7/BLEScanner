//
//  PeripheralDetailsViewController.swift
//  PeripheralDetails
//
//  Created Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit
import Core
import RxSwift
import BlueKit

class PeripheralDetailsViewController: ViewController<PeripheralDetailsViewModel>, Alertable {
    
    // MARK: - Properties
    
    private lazy var headerView: TableViewHeaderView = {
        let headerView = TableViewHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        return activityIndicator
    }()
    
    private var viewData: ViewData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        viewModel.inputs.viewState.onNext(.loaded)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        if parent == nil {
            debugPrint("Back Button pressed.")
            viewModel.inputs.viewControllerDismissed.onNext(())
        }
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
            
            headerView.topAnchor.constraint(equalTo: tableView.topAnchor),
            headerView.leftAnchor.constraint(equalTo: tableView.leftAnchor),
            headerView.rightAnchor.constraint(equalTo: tableView.rightAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 120)
            
        ])
    }
    
    func setupSubviews() {
        view.addSubview(tableView)
        tableView.tableHeaderView = headerView
    }
    
    private func setupNavogationBar() {
        title = "Peripheral Details"
        
        activityIndicator.startAnimating()
        let barButton = UIBarButtonItem(customView: activityIndicator)
        navigationItem.setRightBarButton(barButton, animated: true)
    }
    
    override func setupObservers() {
        viewModel.outputs.viewData
            .subscribe(onNext: { [weak self] viewData in
                guard let self = self else { return }
                
                self.viewData = viewData
                self.headerView.configure(withTitle: self.viewData?.peripheralName, subtitle: self.viewData?.peripheralUUID, description: self.viewData?.peripheralStatus)
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }).disposed(by: viewModel.disposeBag)
        
        viewModel.outputs.showError
            .subscribe(onNext: { [weak self] error in
                guard let self = self else { return }
                
                self.activityIndicator.stopAnimating()
                self.showAlert(title: "Connection Alert", message: error.localizedDescription, cancelActionTitle: "Dismiss", continueActionTitle: nil, handler: nil)
            }).disposed(by: viewModel.disposeBag)
    }
}

// MARK: - UITableViewDataSource

extension PeripheralDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        (viewData?.services.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewData?.advertismentData.count ?? 0
        } else {
            return viewData?.services[section - 1].characteristics.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        
        if indexPath.section == 0 {
            if let advertismentDataDic = viewData?.advertismentDataDic, let advertismentData = viewData?.advertismentData {
                cell.textLabel?.text = CBAdvertisementData.getAdvertisementDataStringValue(advertismentDataDic, key: advertismentData[indexPath.row].key)
                cell.detailTextLabel?.text = CBAdvertisementData.getAdvertisementDataName(advertismentData[indexPath.row].key)
            }
        } else if indexPath.section == 1 {
            cell.textLabel?.text = viewData?.services[indexPath.section - 1].characteristics[indexPath.row].name
            cell.detailTextLabel?.text = viewData?.services[indexPath.section - 1].characteristics[indexPath.row].value
        } else {
            cell.textLabel?.text = viewData?.services[indexPath.section - 1].characteristics[indexPath.row].name
            cell.detailTextLabel?.text = (viewData?.services[indexPath.section - 1].characteristics[indexPath.row].properties ?? "")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let viewData = viewData else { return nil }
        
        if section == 0 {
            return "ADVERTISEMENT DATA"
        } else {
            return viewData.services[section - 1].name
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

// MARK: - UITableViewDataSource

extension PeripheralDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension PeripheralDetailsViewController {
    struct ViewData {
        enum PeripheralState: String {
            case disconnected
            case connecting
            case connected
            case disconnecting
            case unknown
        }
        
        let peripheralName: String?
        let peripheralUUID: String?
        let peripheralStatus: String
        let advertismentData: [(key: String, value: String?)]
        let advertismentDataDic: [String: Any]
        let services: [Service]
    }
}
