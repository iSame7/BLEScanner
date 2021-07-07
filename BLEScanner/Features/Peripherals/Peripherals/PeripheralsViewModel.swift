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
}

struct PeripheralsViewModelOutputs {
    var updatePeripherals = PublishSubject<Void>()
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
            case .loaded:
                self.useCase.getPeripherals().subscribe { event in
                    guard let result = event.element else { return }
                    
                    if let perhipherals = result.perhipherals {
                        self.peripherals = perhipherals
                    } else if let error = result.error {
                        print("Error while scanning for perhipherals: \(error)")
                    }
                    self.outputs.updatePeripherals.onNext(())
                }.disposed(by: self.disposeBag)
            default:
                break
            }
        }).disposed(by: disposeBag)
    }
}
