//
//  PeripheralsUseCase.swift
//  Peripherals
//
//  Created Sameh Mabrouk on 05/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import RxSwift
import BlueKit
import CoreBluetooth
import Core

public protocol PeripheralsInteractable {
    func checkBluetoothState() ->  Observable<CBManagerState?>
    func disconnectPeripheral()
    func getPeripherals() -> Observable<[Peripheral]?>
    func getPeripheralsSorted() -> Observable<[Peripheral]>
    func stopGettingPeripherals()
}

class PeripheralsUseCase: PeripheralsInteractable {
    
    private let service: PeripheralsFetching
    
    init(service: PeripheralsFetching) {
        self.service = service
    }
    
    func checkBluetoothState() -> Observable<CBManagerState?> {
        service.fetchBluetoothState()
    }
    
    func getPeripherals() -> Observable<[Peripheral]?> {
        service.fetchPeripherals()
    }
    
    func disconnectPeripheral() {
        service.disconnectPeripheral()
    }
    
    func getPeripheralsSorted() -> Observable<[Peripheral]> {
        service.sortPeripherals()
    }
    
    func stopGettingPeripherals() {
        service.stopFetchingPeripherals()
    }
}
