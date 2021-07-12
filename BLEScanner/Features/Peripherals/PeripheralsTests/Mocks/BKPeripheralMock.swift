//
//  BKPeripheralMock.swift
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

class BKPeripheralMock: BKPeripheralBLECabable {

    var stubbedIdentifier: UUID!

    var identifier: UUID {
        return stubbedIdentifier
    }

    var stubbedName: String!

    var name: String? {
        return stubbedName
    }

    var stubbedState: CBPeripheralState!

    var state: CBPeripheralState {
        return stubbedState
    }

    var stubbedServices: [CBService]!

    var services: [CBService]? {
        return stubbedServices
    }

    var stubbedServiceResult: CBService!

    func service(withUUID serviceUUID: CBUUIDConvertible) -> CBService? {
        return stubbedServiceResult
    }

    var stubbedCharacteristicResult: CBCharacteristic!

    func characteristic(withUUID characteristicUUID: CBUUIDConvertible,
        ofServiceWithUUID serviceUUID: CBUUIDConvertible) -> CBCharacteristic? {
        return stubbedCharacteristicResult
    }

    var stubbedDescriptorResult: CBDescriptor!

    func descriptor(withUUID descriptorUUID: CBUUIDConvertible,
        ofCharacWithUUID characUUID: CBUUIDConvertible,
        fromServiceWithUUID serviceUUID: CBUUIDConvertible) -> CBDescriptor? {
        return stubbedDescriptorResult
    }

    func connect(withTimeout timeout: TimeInterval?, completion: @escaping ConnectPeripheralCompletion) {}

    func disconnect(completion: @escaping DisconnectPeripheralCompletion) {}

    func readRSSI(completion: @escaping ReadRSSIRequestCompletion) {}

    func discoverServices(withUUIDs serviceUUIDs: [CBUUIDConvertible]?,
        completion: @escaping ServiceRequestCompletion) {}

    func discoverIncludedServices(withUUIDs includedServiceUUIDs: [CBUUIDConvertible]?,
        ofServiceWithUUID serviceUUID: CBUUIDConvertible,
        completion: @escaping ServiceRequestCompletion) {}

    func discoverCharacteristics(withUUIDs characteristicUUIDs: [CBUUIDConvertible]?,
        ofServiceWithUUID serviceUUID: CBUUIDConvertible,
        completion: @escaping CharacteristicRequestCompletion) {}

    func discoverDescriptors(ofCharacWithUUID characUUID: CBUUIDConvertible,
        fromServiceWithUUID serviceUUID: CBUUIDConvertible,
        completion: @escaping DescriptorRequestCompletion) {}

    func discoverDescriptors(ofCharac charac: CBCharacteristic,
        completion: @escaping DescriptorRequestCompletion) {}

    func readValue(ofCharacWithUUID characUUID: CBUUIDConvertible,
        fromServiceWithUUID serviceUUID: CBUUIDConvertible,
        completion: @escaping ReadCharacRequestCompletion) {}

    func readValue(ofCharac charac: CBCharacteristic,
        completion: @escaping ReadCharacRequestCompletion) {}

    func readValue(ofDescriptorWithUUID descriptorUUID: CBUUIDConvertible,
        fromCharacUUID characUUID: CBUUIDConvertible,
        ofServiceUUID serviceUUID: CBUUIDConvertible,
        completion: @escaping ReadDescriptorRequestCompletion) {}

    func readValue(ofDescriptor descriptor: CBDescriptor,
        completion: @escaping ReadDescriptorRequestCompletion) {}

    func writeValue(ofCharacWithUUID characUUID: CBUUIDConvertible,
        fromServiceWithUUID serviceUUID: CBUUIDConvertible,
        value: Data,
        type: CBCharacteristicWriteType,
        completion: @escaping WriteRequestCompletion) {}

    func writeValue(ofCharac charac: CBCharacteristic,
        value: Data,
        type: CBCharacteristicWriteType,
        completion: @escaping WriteRequestCompletion) {}

    func writeValue(ofDescriptorWithUUID descriptorUUID: CBUUIDConvertible,
        fromCharacWithUUID characUUID: CBUUIDConvertible,
        ofServiceWithUUID serviceUUID: CBUUIDConvertible,
        value: Data,
        completion: @escaping WriteRequestCompletion) {}

    func writeValue(ofDescriptor descriptor: CBDescriptor,
        value: Data,
        completion: @escaping WriteRequestCompletion) {}

    func setNotifyValue(toEnabled enabled: Bool,
        forCharacWithUUID characUUID: CBUUIDConvertible,
        ofServiceWithUUID serviceUUID: CBUUIDConvertible,
        completion: @escaping UpdateNotificationStateCompletion) {}

    func setNotifyValue(toEnabled enabled: Bool,
        ofCharac charac: CBCharacteristic,
        completion: @escaping UpdateNotificationStateCompletion) {}
}
