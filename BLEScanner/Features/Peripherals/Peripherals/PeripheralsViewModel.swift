//
//  PeripheralsViewModel.swift
//  Peripherals
//
//  Created Sameh Mabrouk on 05/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import RxSwift
import Core
import BlueKit

protocol PeripheralsViewModellable: ViewModellable {
    var disposeBag: DisposeBag { get }
    var inputs: PeripheralsViewModelInputs { get }
    var outputs: PeripheralsViewModelOutputs { get }
}

struct PeripheralsViewModelInputs {
    var viewState = PublishSubject<ViewState>()
    var itemTapped = PublishSubject<Peripheral>()
    var sortPeripherals = PublishSubject<Void>()
}

struct PeripheralsViewModelOutputs {
    var updatePeripherals = PublishSubject<Void>()
    var showPeripheralDetails = PublishSubject<Peripheral>()
    let hideErrorView = PublishSubject<Bool>()
}

class PeripheralsViewModel: PeripheralsViewModellable {
    
    let disposeBag = DisposeBag()
    let inputs = PeripheralsViewModelInputs()
    let outputs = PeripheralsViewModelOutputs()
    var useCase: PeripheralsInteractable
    
    var peripherals = [Peripheral]()
    
    init(useCase: PeripheralsInteractable) {
        self.useCase = useCase
        
        setupObservables()
    }
}

// MARK: - Observables

private extension PeripheralsViewModel {
    
    func setupObservables() {
        inputs.viewState.subscribe(onNext: { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .loaded, .appeared:
                self.useCase.checkBluetoothState().subscribe { event in
                    guard let state = event.element! else { return }
                    
                    print("[PeripheralsViewModel] state: \(state)")
                    switch state {
                    case .resetting:
                        print("[PeripheralsViewModel] State : Resetting")
                    case .poweredOn:
                        print(" [PeripheralsViewModel] State : Powered On")
                        self.useCase.getPeripherals().subscribe { event in
                            guard let result = event.element else { return }
                            
                            if let perhipherals = result.peripherals {
                                self.peripherals = perhipherals
                            } else if let error = result.error {
                                print("Error while scanning for perhipherals: \(error)")
                            }
                            self.outputs.updatePeripherals.onNext(())
                        }.disposed(by: self.disposeBag)
                        self.outputs.hideErrorView.onNext(true)
                    case .poweredOff:
                        print(" [PeripheralsViewModel] State : Powered Off")
                        fallthrough
                    case .unauthorized:
                        print("[PeripheralsViewModel] State : Unauthorized")
                        fallthrough
                    case .unknown:
                        print("[PeripheralsViewModel] State : Unknown")
                        fallthrough
                    case .unsupported:
                        print("[PeripheralsViewModel] State : Unsupported")
                        self.useCase.stopGettingPeripherals()
                        self.useCase.disconnectPeripheral()
                        self.outputs.hideErrorView.onNext(false)
                    @unknown default:
                        print("[PeripheralsViewModel] State : Unknown")
                    }
                }.disposed(by: self.disposeBag)
            default:
                break
            }
        }).disposed(by: disposeBag)
        
        inputs.sortPeripherals.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            
            self.useCase.getPeripheralsSorted().subscribe { event in
                guard let peripherals = event.element else { return }
                
                self.peripherals = peripherals
                self.outputs.updatePeripherals.onNext(())
            }.disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
        
        inputs.itemTapped.subscribe(onNext: { [weak self] peripheral in
            guard let self = self else { return }
            
            self.useCase.stopGettingPeripherals()
            self.outputs.showPeripheralDetails.onNext(peripheral)
        }).disposed(by: disposeBag)
    }
}
