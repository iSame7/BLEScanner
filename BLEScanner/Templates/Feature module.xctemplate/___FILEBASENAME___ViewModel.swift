//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import RxSwift
import Utils

protocol ___VARIABLE_productName:identifier___ViewModellable: class {
    var disposeBag: DisposeBag { get }
    var inputs: ___VARIABLE_productName:identifier___ViewModelInputs { get }
    var outputs: ___VARIABLE_productName:identifier___ViewModelOutputs { get }
}

struct ___VARIABLE_productName:identifier___ViewModelInputs {}

struct ___VARIABLE_productName:identifier___ViewModelOutputs {}

class ___VARIABLE_productName:identifier___ViewModel: ___VARIABLE_productName:identifier___ViewModellable {

    let disposeBag = DisposeBag()
    let inputs = ___VARIABLE_productName:identifier___ViewModelInputs()
    let outputs = ___VARIABLE_productName:identifier___ViewModelOutputs()
    var useCase: ___VARIABLE_productName:identifier___Interactable

    init(useCase: ___VARIABLE_productName:identifier___Interactable) {
        self.useCase = useCase
    }
}

// MARK: - Observables

private extension ___VARIABLE_productName:identifier___ViewModel {

    func setupObservables() {}
}
