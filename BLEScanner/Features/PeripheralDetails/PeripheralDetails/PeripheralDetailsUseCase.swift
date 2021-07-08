//
//  PeripheralDetailsUseCase.swift
//  PeripheralDetails
//
//  Created Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import RxSwift

public protocol PeripheralDetailsInteractable {
}

class PeripheralDetailsUseCase: PeripheralDetailsInteractable {

    private let service: PeripheralDetailsServicePerforming
    
    init(service: PeripheralDetailsServicePerforming) {
        self.service = service
    }
}
