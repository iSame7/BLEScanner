//
//  PeripheralDetailsViewModel.swift
//  PeripheralDetails
//
//  Created Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import RxSwift
import Core

protocol PeripheralDetailsViewModellable: ViewModellable {
    var disposeBag: DisposeBag { get }
    var inputs: PeripheralDetailsViewModelInputs { get }
    var outputs: PeripheralDetailsViewModelOutputs { get }
}

struct PeripheralDetailsViewModelInputs {
    var viewState = PublishSubject<ViewState>()
    var viewControllerDismissed = PublishSubject<Void>()
}

struct PeripheralDetailsViewModelOutputs {
    var viewData = PublishSubject<PeripheralDetailsViewController.ViewData>()
    var viewControllerDismissed = PublishSubject<Void>()
    var showError = PublishSubject<Error>()
}

class PeripheralDetailsViewModel: PeripheralDetailsViewModellable {

    let disposeBag = DisposeBag()
    let inputs = PeripheralDetailsViewModelInputs()
    let outputs = PeripheralDetailsViewModelOutputs()
    private let useCase: PeripheralDetailsInteractable
    let peripheral: Peripheral
    
    init(useCase: PeripheralDetailsInteractable, peripheral: Peripheral) {
        self.useCase = useCase
        self.peripheral = peripheral
        
        setupObservables()
    }
}

// MARK: - Observables

private extension PeripheralDetailsViewModel {

    func setupObservables() {
        inputs.viewState.subscribe(onNext: { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .loaded:
                self.useCase.getServices().subscribe { event in
                    guard let result = event.element else { return }

                    if let services = result.services, !services.isEmpty {
                        self.outputs.viewData.onNext(self.mapPeripheralDataToViewData(sevices: services))
                    } else if let error = result.error, let services = result.services, services.isEmpty {
                        self.outputs.showError.onNext(error)
                    }
                }.disposed(by: self.disposeBag)

            default:
                break
            }
        }).disposed(by: disposeBag)
        
        inputs.viewControllerDismissed.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            
            self.outputs.viewControllerDismissed.onNext(())            
        }).disposed(by: disposeBag)
    }
}

// MARK: - Mapping

private extension PeripheralDetailsViewModel {
    
    func mapPeripheralDataToViewData(sevices: [Service]) -> PeripheralDetailsViewController.ViewData {
        let advertismentData = self.peripheral.advertismentData.map { (key: String, value: Any) -> (String, String) in
            var newValue = value
            if key == "kCBAdvDataIsConnectable" {
                newValue = (value as? Bool == true) ? "Yes" : "NO"
            }
            return (key, String(describing: newValue))
        }
        
        var peripheralState: PeripheralDetailsViewController.ViewData.PeripheralState
        switch self.peripheral.bkPeripheral.state {
        case .connected:
            peripheralState = .connected
        case .connecting:
            peripheralState = .connecting
        case .disconnected:
            peripheralState = .disconnected
        case .disconnecting:
            peripheralState = .disconnecting
        @unknown default:
            assertionFailure("Unknown peripheral status")
            peripheralState = .unknown
        }
        return PeripheralDetailsViewController.ViewData(peripheralName: self.peripheral.bkPeripheral.name, peripheralUUID: self.peripheral.bkPeripheral.identifier.uuidString, peripheralStatus: peripheralState.rawValue, advertismentData: advertismentData, advertismentDataDic: self.peripheral.advertismentData, services: sevices)
    }
}
