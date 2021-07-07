//
//  PeripheralsUseCase.swift
//  Peripherals
//
//  Created Sameh Mabrouk on 05/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import RxSwift
import BlueKit
import Core

public protocol PeripheralsInteractable {
    func getPeripherals() -> Observable<(perhipherals: [Peripheral]?, error: BKError?)>
}

class PeripheralsUseCase: PeripheralsInteractable {
    
    private let service: PeripheralsFetching
    
    init(service: PeripheralsFetching) {
        self.service = service
    }
    
    func getPeripherals() -> Observable<(perhipherals: [Peripheral]?, error: BKError?)> {
        service.fetchPeripherals()
    }
}
