//
//  PeripheralsUseCaseMock.swift
//  PeripheralsTests
//
//  Created by Sameh Mabrouk on 12/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import BlueKit
import RxSwift
import Core
import CoreBluetooth

@testable import Peripherals

class PeripheralsUseCaseMock: PeripheralsInteractable {

    var invokedCheckBluetoothState = false
    var invokedCheckBluetoothStateCount = 0
    var stubbedCheckBluetoothStateResult: Observable<CBManagerState?>!

    func checkBluetoothState() ->  Observable<CBManagerState?> {
        invokedCheckBluetoothState = true
        invokedCheckBluetoothStateCount += 1
        return stubbedCheckBluetoothStateResult
    }

    var invokedDisconnectPeripheral = false
    var invokedDisconnectPeripheralCount = 0

    func disconnectPeripheral() {
        invokedDisconnectPeripheral = true
        invokedDisconnectPeripheralCount += 1
    }

    var invokedGetPeripherals = false
    var invokedGetPeripheralsCount = 0
    var stubbedGetPeripheralsResult: Observable<[Peripheral]?>!

    func getPeripherals() -> Observable<[Peripheral]?> {
        invokedGetPeripherals = true
        invokedGetPeripheralsCount += 1
        return stubbedGetPeripheralsResult
    }

    var invokedGetPeripheralsSorted = false
    var invokedGetPeripheralsSortedCount = 0
    var stubbedGetPeripheralsSortedResult: Observable<[Peripheral]>!

    func getPeripheralsSorted() -> Observable<[Peripheral]> {
        invokedGetPeripheralsSorted = true
        invokedGetPeripheralsSortedCount += 1
        return stubbedGetPeripheralsSortedResult
    }

    var invokedStopGettingPeripherals = false
    var invokedStopGettingPeripheralsCount = 0

    func stopGettingPeripherals() {
        invokedStopGettingPeripherals = true
        invokedStopGettingPeripheralsCount += 1
    }
}
