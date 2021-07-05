//
//  PeripheralsUseCase.swift
//  Peripherals
//
//  Created Sameh Mabrouk on 05/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import RxSwift

public protocol PeripheralsInteractable {
    func doSomething() -> Single<Bool>
}

class PeripheralsUseCase: PeripheralsInteractable {

    private let service: PeripheralsServicePerforming
    
    init(service: PeripheralsServicePerforming) {
        self.service = service
    }
    
    func doSomething() -> Single<Bool> {
        service.doSomething()
    }
}
