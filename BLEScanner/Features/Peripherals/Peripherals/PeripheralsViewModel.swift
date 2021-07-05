//
//  PeripheralsViewModel.swift
//  Peripherals
//
//  Created Sameh Mabrouk on 05/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import RxSwift
import Utils

protocol PeripheralsViewModellable: class {
    var disposeBag: DisposeBag { get }
    var inputs: PeripheralsViewModelInputs { get }
    var outputs: PeripheralsViewModelOutputs { get }
}

struct PeripheralsViewModelInputs {}

struct PeripheralsViewModelOutputs {}

class PeripheralsViewModel: PeripheralsViewModellable {

    let disposeBag = DisposeBag()
    let inputs = PeripheralsViewModelInputs()
    let outputs = PeripheralsViewModelOutputs()
    var useCase: PeripheralsInteractable

    init(useCase: PeripheralsInteractable) {
        self.useCase = useCase
    }
}

// MARK: - Observables

private extension PeripheralsViewModel {

    func setupObservables() {}
}
