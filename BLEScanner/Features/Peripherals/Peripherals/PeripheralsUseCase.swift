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
    func getPeripherals() -> Observable<(peripherals: [Peripheral]?, error: BKError?)>
    func getPeripheralsSorted() -> Observable<[Peripheral]>
    func stopGettingPeripherals()
}

class PeripheralsUseCase: PeripheralsInteractable {
    
    private let service: PeripheralsFetching
    
    init(service: PeripheralsFetching) {
        self.service = service
    }
    
    func getPeripherals() -> Observable<(peripherals: [Peripheral]?, error: BKError?)> {
        service.fetchPeripherals()
    }
    
    func getPeripheralsSorted() -> Observable<[Peripheral]> {
        service.sortPeripherals()
    }
    
    func stopGettingPeripherals() {
        service.stopFetchingperipherals()
    }
}
