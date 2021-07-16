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

    var invokedIdentifierGetter = false
    var invokedIdentifierGetterCount = 0
    var stubbedIdentifier: UUID!

    var identifier: UUID {
        invokedIdentifierGetter = true
        invokedIdentifierGetterCount += 1
        return stubbedIdentifier
    }

    var invokedNameGetter = false
    var invokedNameGetterCount = 0
    var stubbedName: String!

    var name: String? {
        invokedNameGetter = true
        invokedNameGetterCount += 1
        return stubbedName
    }

    var invokedStateGetter = false
    var invokedStateGetterCount = 0
    var stubbedState: CBPeripheralState!

    var state: CBPeripheralState {
        invokedStateGetter = true
        invokedStateGetterCount += 1
        return stubbedState
    }

    var invokedServicesGetter = false
    var invokedServicesGetterCount = 0
    var stubbedServices: [CBService]!

    var services: [CBService]? {
        invokedServicesGetter = true
        invokedServicesGetterCount += 1
        return stubbedServices
    }

    var invokedDiscoverServices = false
    var invokedDiscoverServicesCount = 0
    var invokedDiscoverServicesParameters: (serviceUUIDs: [CBUUID]?, Void)?
    var invokedDiscoverServicesParametersList = [(serviceUUIDs: [CBUUID]?, Void)]()

    func discoverServices(_ serviceUUIDs: [CBUUID]?) {
        invokedDiscoverServices = true
        invokedDiscoverServicesCount += 1
        invokedDiscoverServicesParameters = (serviceUUIDs, ())
        invokedDiscoverServicesParametersList.append((serviceUUIDs, ()))
    }

    var invokedDiscoverIncludedServices = false
    var invokedDiscoverIncludedServicesCount = 0
    var invokedDiscoverIncludedServicesParameters: (includedServiceUUIDs: [CBUUID]?, service: CBService)?
    var invokedDiscoverIncludedServicesParametersList = [(includedServiceUUIDs: [CBUUID]?, service: CBService)]()

    func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?, for service: CBService) {
        invokedDiscoverIncludedServices = true
        invokedDiscoverIncludedServicesCount += 1
        invokedDiscoverIncludedServicesParameters = (includedServiceUUIDs, service)
        invokedDiscoverIncludedServicesParametersList.append((includedServiceUUIDs, service))
    }

    var invokedDiscoverCharacteristics = false
    var invokedDiscoverCharacteristicsCount = 0
    var invokedDiscoverCharacteristicsParameters: (characteristicUUIDs: [CBUUID]?, service: CBService)?
    var invokedDiscoverCharacteristicsParametersList = [(characteristicUUIDs: [CBUUID]?, service: CBService)]()

    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
        invokedDiscoverCharacteristics = true
        invokedDiscoverCharacteristicsCount += 1
        invokedDiscoverCharacteristicsParameters = (characteristicUUIDs, service)
        invokedDiscoverCharacteristicsParametersList.append((characteristicUUIDs, service))
    }

    var invokedReadValueForCBCharacteristic = false
    var invokedReadValueForCBCharacteristicCount = 0
    var invokedReadValueForCBCharacteristicParameters: (characteristic: CBCharacteristic, Void)?
    var invokedReadValueForCBCharacteristicParametersList = [(characteristic: CBCharacteristic, Void)]()

    func readValue(for characteristic: CBCharacteristic) {
        invokedReadValueForCBCharacteristic = true
        invokedReadValueForCBCharacteristicCount += 1
        invokedReadValueForCBCharacteristicParameters = (characteristic, ())
        invokedReadValueForCBCharacteristicParametersList.append((characteristic, ()))
    }

    var invokedWriteValueFor = false
    var invokedWriteValueForCount = 0
    var invokedWriteValueForParameters: (data: Data, characteristic: CBCharacteristic, type: CBCharacteristicWriteType)?
    var invokedWriteValueForParametersList = [(data: Data, characteristic: CBCharacteristic, type: CBCharacteristicWriteType)]()

    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        invokedWriteValueFor = true
        invokedWriteValueForCount += 1
        invokedWriteValueForParameters = (data, characteristic, type)
        invokedWriteValueForParametersList.append((data, characteristic, type))
    }

    var invokedSetNotifyValue = false
    var invokedSetNotifyValueCount = 0
    var invokedSetNotifyValueParameters: (enabled: Bool, characteristic: CBCharacteristic)?
    var invokedSetNotifyValueParametersList = [(enabled: Bool, characteristic: CBCharacteristic)]()

    func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
        invokedSetNotifyValue = true
        invokedSetNotifyValueCount += 1
        invokedSetNotifyValueParameters = (enabled, characteristic)
        invokedSetNotifyValueParametersList.append((enabled, characteristic))
    }

    var invokedDiscoverDescriptors = false
    var invokedDiscoverDescriptorsCount = 0
    var invokedDiscoverDescriptorsParameters: (characteristic: CBCharacteristic, Void)?
    var invokedDiscoverDescriptorsParametersList = [(characteristic: CBCharacteristic, Void)]()

    func discoverDescriptors(for characteristic: CBCharacteristic) {
        invokedDiscoverDescriptors = true
        invokedDiscoverDescriptorsCount += 1
        invokedDiscoverDescriptorsParameters = (characteristic, ())
        invokedDiscoverDescriptorsParametersList.append((characteristic, ()))
    }

    var invokedReadValueForCBDescriptor = false
    var invokedReadValueForCBDescriptorCount = 0
    var invokedReadValueForCBDescriptorParameters: (descriptor: CBDescriptor, Void)?
    var invokedReadValueForCBDescriptorParametersList = [(descriptor: CBDescriptor, Void)]()

    func readValue(for descriptor: CBDescriptor) {
        invokedReadValueForCBDescriptor = true
        invokedReadValueForCBDescriptorCount += 1
        invokedReadValueForCBDescriptorParameters = (descriptor, ())
        invokedReadValueForCBDescriptorParametersList.append((descriptor, ()))
    }

    var invokedWriteValue = false
    var invokedWriteValueCount = 0
    var invokedWriteValueParameters: (data: Data, descriptor: CBDescriptor)?
    var invokedWriteValueParametersList = [(data: Data, descriptor: CBDescriptor)]()

    func writeValue(_ data: Data, for descriptor: CBDescriptor) {
        invokedWriteValue = true
        invokedWriteValueCount += 1
        invokedWriteValueParameters = (data, descriptor)
        invokedWriteValueParametersList.append((data, descriptor))
    }
}
