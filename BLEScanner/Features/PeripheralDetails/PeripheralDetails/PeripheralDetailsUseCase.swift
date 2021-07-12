//
//  PeripheralDetailsUseCase.swift
//  PeripheralDetails
//
//  Created Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import RxSwift
import Core

public protocol PeripheralDetailsInteractable {
    func getServices() -> Observable<(services: [Service]?, error: Error?)>
}

class PeripheralDetailsUseCase: PeripheralDetailsInteractable {

    private let service: PeripheralDetailsServiceFetching
    
    init(service: PeripheralDetailsServiceFetching) {
        self.service = service
    }
    
    func getServices() -> Observable<(services: [Service]?, error: Error?)> {
        service.fetchServices()
    }
}
