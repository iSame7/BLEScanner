//
//  PeripheralDetailsViewModel.swift
//  PeripheralDetails
//
//  Created Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import RxSwift
import Core

protocol PeripheralDetailsViewModellable: ViewModellable {
    var disposeBag: DisposeBag { get }
    var inputs: PeripheralDetailsViewModelInputs { get }
    var outputs: PeripheralDetailsViewModelOutputs { get }
}

struct PeripheralDetailsViewModelInputs {}

struct PeripheralDetailsViewModelOutputs {}

class PeripheralDetailsViewModel: PeripheralDetailsViewModellable {

    let disposeBag = DisposeBag()
    let inputs = PeripheralDetailsViewModelInputs()
    let outputs = PeripheralDetailsViewModelOutputs()
    var useCase: PeripheralDetailsInteractable

    init(useCase: PeripheralDetailsInteractable) {
        self.useCase = useCase
    }
}

// MARK: - Observables

private extension PeripheralDetailsViewModel {

    func setupObservables() {}
}
