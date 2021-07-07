//
//  Peripheral.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 06/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import CoreBluetooth

public typealias rssi = Int
public typealias isNotifying = Bool

public typealias ReadRSSIRequestCompletion = (_ result: Result<rssi, Error>) -> Void
public typealias ServiceRequestCompletion = (_ result: Result<[CBService], Error>) -> Void
public typealias CharacteristicRequestCompletion = (_ result: Result<[CBCharacteristic], Error>) -> Void
public typealias DescriptorRequestCompletion = (_ result: Result<[CBDescriptor], Error>) -> Void
public typealias ReadCharacRequestCompletion = (_ result: Result<Data, Error>) -> Void
public typealias ReadDescriptorRequestCompletion = (_ result: Result<DescriptorValue, Error>) -> Void
public typealias WriteRequestCompletion = (_ result: Result<Void, Error>) -> Void
public typealias UpdateNotificationStateCompletion = (_ result: Result<isNotifying, Error>) -> Void

public protocol BKPeripheralBLECabable {
    var identifier: UUID { get }
    var name: String? { get }
    var state: CBPeripheralState { get }
    var services: [CBService]? { get }
    func service(withUUID serviceUUID: CBUUIDConvertible) -> CBService?
    func characteristic(withUUID characteristicUUID: CBUUIDConvertible,
                               ofServiceWithUUID serviceUUID: CBUUIDConvertible) -> CBCharacteristic?
    func descriptor(withUUID descriptorUUID: CBUUIDConvertible,
                           ofCharacWithUUID characUUID: CBUUIDConvertible,
                           fromServiceWithUUID serviceUUID: CBUUIDConvertible) -> CBDescriptor?
    func connect(withTimeout timeout: TimeInterval?, completion: @escaping ConnectPeripheralCompletion)
    func disconnect(completion: @escaping DisconnectPeripheralCompletion)
    func readRSSI(completion: @escaping ReadRSSIRequestCompletion)
    func discoverServices(withUUIDs serviceUUIDs: [CBUUIDConvertible]?,
                                 completion: @escaping ServiceRequestCompletion)
    func discoverIncludedServices(withUUIDs includedServiceUUIDs: [CBUUIDConvertible]?,
                                         ofServiceWithUUID serviceUUID: CBUUIDConvertible,
                                         completion: @escaping ServiceRequestCompletion)
    func discoverCharacteristics(withUUIDs characteristicUUIDs: [CBUUIDConvertible]?,
                                        ofServiceWithUUID serviceUUID: CBUUIDConvertible,
                                        completion: @escaping CharacteristicRequestCompletion)
    func discoverDescriptors(ofCharacWithUUID characUUID: CBUUIDConvertible,
                                    fromServiceWithUUID serviceUUID: CBUUIDConvertible,
                                    completion: @escaping DescriptorRequestCompletion)
    func discoverDescriptors(ofCharac charac: CBCharacteristic,
                                    completion: @escaping DescriptorRequestCompletion)
    func readValue(ofCharacWithUUID characUUID: CBUUIDConvertible,
                          fromServiceWithUUID serviceUUID: CBUUIDConvertible,
                          completion: @escaping ReadCharacRequestCompletion)
    func readValue(ofCharac charac: CBCharacteristic,
                          completion: @escaping ReadCharacRequestCompletion)
    func readValue(ofDescriptorWithUUID descriptorUUID: CBUUIDConvertible,
                          fromCharacUUID characUUID: CBUUIDConvertible,
                          ofServiceUUID serviceUUID: CBUUIDConvertible,
                          completion: @escaping ReadDescriptorRequestCompletion)
    func readValue(ofDescriptor descriptor: CBDescriptor,
                          completion: @escaping ReadDescriptorRequestCompletion)
    func writeValue(ofCharacWithUUID characUUID: CBUUIDConvertible,
                           fromServiceWithUUID serviceUUID: CBUUIDConvertible,
                           value: Data,
                           type: CBCharacteristicWriteType,
                           completion: @escaping WriteRequestCompletion)
    func writeValue(ofCharac charac: CBCharacteristic,
                           value: Data,
                           type: CBCharacteristicWriteType,
                           completion: @escaping WriteRequestCompletion)
    func writeValue(ofDescriptorWithUUID descriptorUUID: CBUUIDConvertible,
                           fromCharacWithUUID characUUID: CBUUIDConvertible,
                           ofServiceWithUUID serviceUUID: CBUUIDConvertible,
                           value: Data,
                           completion: @escaping WriteRequestCompletion)
    func writeValue(ofDescriptor descriptor: CBDescriptor,
                           value: Data,
                           completion: @escaping WriteRequestCompletion)
    func setNotifyValue(toEnabled enabled: Bool,
                               forCharacWithUUID characUUID: CBUUIDConvertible,
                               ofServiceWithUUID serviceUUID: CBUUIDConvertible,
                               completion: @escaping UpdateNotificationStateCompletion)
    func setNotifyValue(toEnabled enabled: Bool,
                               ofCharac charac: CBCharacteristic,
                               completion: @escaping UpdateNotificationStateCompletion)
    
}
/// A wrapper on top of a CBPeripheral  used to run CBPeripheral related functions with closures instead of CBPeripheralDelegate.
public final class BKPeripheral {
    
    private var peripheralProxy: BKPeripheralProxy!

    init(peripheral: CBPeripheral) {
        self.peripheralProxy = BKPeripheralProxy(cbPeripheral: peripheral, peripheral: self)
    }
}

extension BKPeripheral {
    
    /// The name of a `Notification` posted by a `Peripheral` instance when it becomes disconnected
    public static let peripheralDisconnected = Notification.Name(rawValue: "BKPeripheralDisconnected")
    
    /// The name of a `Notification` posted by a `Peripheral` instance when its `CBPeripheral` name value changes.
    public static let PeripheralNameUpdate = Notification.Name(rawValue: "BKPeripheralNameUpdate")

    /// The name of a `Notification` posted by a `Peripheral` instance when some of its `CBPeripheral` services are invalidated.
    public static let PeripheralModifedServices = Notification.Name(rawValue: "SwiftyBluetooth_PeripheralModifedServices")
    
    /// The name of a `Notification` posted by a `Peripheral` instance when one of the characteristic you have subcribed for update from
    /// changes its value.
    public static let PeripheralCharacteristicValueUpdate = Notification.Name(rawValue: "SwiftyBluetooth_PharacteristicValueUpdate")
}

// MARK: - PeripheralBLECabable

extension BKPeripheral: BKPeripheralBLECabable {
    
    public var identifier: UUID {
        return peripheralProxy.cbPeripheral.identifier
    }
    
    public var name: String? {
        return peripheralProxy.cbPeripheral.name
    }
    
    public var state: CBPeripheralState {
        return peripheralProxy.cbPeripheral.state
    }
    
    public var services: [CBService]? {
        return peripheralProxy.cbPeripheral.services
    }
    
    public func service(withUUID serviceUUID: CBUUIDConvertible) -> CBService? {
        return peripheralProxy.cbPeripheral
            .serviceWithUUID(serviceUUID.uuidRepresentation)
    }
    
    public func characteristic(withUUID characteristicUUID: CBUUIDConvertible, ofServiceWithUUID serviceUUID: CBUUIDConvertible) -> CBCharacteristic? {
        return peripheralProxy.cbPeripheral
            .serviceWithUUID(serviceUUID.uuidRepresentation)?
            .characteristicWithUUID(characteristicUUID.uuidRepresentation)
    }
    
    public func descriptor(withUUID descriptorUUID: CBUUIDConvertible, ofCharacWithUUID characUUID: CBUUIDConvertible, fromServiceWithUUID serviceUUID: CBUUIDConvertible) -> CBDescriptor? {
        return peripheralProxy.cbPeripheral
            .serviceWithUUID(serviceUUID.uuidRepresentation)?
            .characteristicWithUUID(characUUID.uuidRepresentation)?
            .descriptorWithUUID(descriptorUUID.uuidRepresentation)
    }
    
    public func connect(withTimeout timeout: TimeInterval?, completion: @escaping ConnectPeripheralCompletion) {
        if let timeout = timeout {
            peripheralProxy.connect(timeout: timeout, completion)
        } else {
            peripheralProxy.connect(timeout: TimeInterval.infinity, completion)
        }
    }
    
    public func disconnect(completion: @escaping DisconnectPeripheralCompletion) {
        peripheralProxy.disconnect(completion)
    }
    
    public func readRSSI(completion: @escaping ReadRSSIRequestCompletion) {
        peripheralProxy.readRSSI(completion)
    }
    
    public func discoverServices(withUUIDs serviceUUIDs: [CBUUIDConvertible]?, completion: @escaping ServiceRequestCompletion) {
        peripheralProxy.discoverServices(extractCBUUIDs(serviceUUIDs), completion: completion)
    }
    
    public func discoverIncludedServices(withUUIDs includedServiceUUIDs: [CBUUIDConvertible]?, ofServiceWithUUID serviceUUID: CBUUIDConvertible, completion: @escaping ServiceRequestCompletion) {
        peripheralProxy.discoverIncludedServices(extractCBUUIDs(includedServiceUUIDs),
                                                      forService: serviceUUID.uuidRepresentation,
                                                      completion: completion)
    }
    
    public func discoverCharacteristics(withUUIDs characteristicUUIDs: [CBUUIDConvertible]?, ofServiceWithUUID serviceUUID: CBUUIDConvertible, completion: @escaping CharacteristicRequestCompletion) {
        peripheralProxy.discoverCharacteristics(extractCBUUIDs(characteristicUUIDs),
                                                     forService: serviceUUID.uuidRepresentation,
                                                     completion: completion)
    }
    
    public func discoverDescriptors(ofCharacWithUUID characUUID: CBUUIDConvertible, fromServiceWithUUID serviceUUID: CBUUIDConvertible, completion: @escaping DescriptorRequestCompletion) {
        peripheralProxy.discoverDescriptorsForCharacteristic(characUUID.uuidRepresentation,
                                                                  serviceUUID: serviceUUID.uuidRepresentation,
                                                                  completion: completion)
    }
    
    public func discoverDescriptors(ofCharac charac: CBCharacteristic, completion: @escaping DescriptorRequestCompletion) {
        discoverDescriptors(ofCharacWithUUID: charac,
                                 fromServiceWithUUID: charac.service,
                                 completion: completion)
    }
    
    public func readValue(ofCharacWithUUID characUUID: CBUUIDConvertible, fromServiceWithUUID serviceUUID: CBUUIDConvertible, completion: @escaping ReadCharacRequestCompletion) {
        peripheralProxy.readCharacteristic(characUUID.uuidRepresentation,
                                                serviceUUID: serviceUUID.uuidRepresentation,
                                                completion: completion)
    }
    
    public func readValue(ofCharac charac: CBCharacteristic, completion: @escaping ReadCharacRequestCompletion) {
        readValue(ofCharacWithUUID: charac,
                       fromServiceWithUUID: charac.service,
                       completion: completion)
    }
    
    public func readValue(ofDescriptorWithUUID descriptorUUID: CBUUIDConvertible, fromCharacUUID characUUID: CBUUIDConvertible, ofServiceUUID serviceUUID: CBUUIDConvertible, completion: @escaping ReadDescriptorRequestCompletion) {
        peripheralProxy.readDescriptor(descriptorUUID.uuidRepresentation,
                                            characteristicUUID: characUUID.uuidRepresentation,
                                            serviceUUID: serviceUUID.uuidRepresentation,
                                            completion: completion)
    }
    
    public func readValue(ofDescriptor descriptor: CBDescriptor, completion: @escaping ReadDescriptorRequestCompletion) {
        readValue(ofDescriptorWithUUID: descriptor,
                       fromCharacUUID: descriptor.characteristic,
                       ofServiceUUID: descriptor.characteristic.service,
                       completion: completion)
    }
    
    public func writeValue(ofCharacWithUUID characUUID: CBUUIDConvertible, fromServiceWithUUID serviceUUID: CBUUIDConvertible, value: Data, type: CBCharacteristicWriteType, completion: @escaping WriteRequestCompletion) {
        peripheralProxy.writeCharacteristicValue(characUUID.uuidRepresentation,
                                                      serviceUUID: serviceUUID.uuidRepresentation,
                                                      value: value,
                                                      type: type,
                                                      completion: completion)
    }
    
    public func writeValue(ofCharac charac: CBCharacteristic, value: Data, type: CBCharacteristicWriteType, completion: @escaping WriteRequestCompletion) {
        writeValue(ofCharacWithUUID: charac,
                        fromServiceWithUUID: charac.service,
                        value: value,
                        type: type,
                        completion: completion)
    }
    
    public func writeValue(ofDescriptorWithUUID descriptorUUID: CBUUIDConvertible, fromCharacWithUUID characUUID: CBUUIDConvertible, ofServiceWithUUID serviceUUID: CBUUIDConvertible, value: Data, completion: @escaping WriteRequestCompletion) {
        peripheralProxy.writeDescriptorValue(descriptorUUID.uuidRepresentation,
                                                  characteristicUUID: characUUID.uuidRepresentation,
                                                  serviceUUID: serviceUUID.uuidRepresentation,
                                                  value: value,
                                                  completion: completion)
    }
    
    public func writeValue(ofDescriptor descriptor: CBDescriptor, value: Data, completion: @escaping WriteRequestCompletion) {
        writeValue(ofDescriptorWithUUID: descriptor,
                        fromCharacWithUUID: descriptor.characteristic,
                        ofServiceWithUUID: descriptor.characteristic.service,
                        value: value,
                        completion: completion)
    }
    
    public func setNotifyValue(toEnabled enabled: Bool, forCharacWithUUID characUUID: CBUUIDConvertible, ofServiceWithUUID serviceUUID: CBUUIDConvertible, completion: @escaping UpdateNotificationStateCompletion) {
        peripheralProxy.setNotifyValueForCharacteristic(enabled,
                                                             characteristicUUID: characUUID.uuidRepresentation,
                                                             serviceUUID: serviceUUID.uuidRepresentation,
                                                             completion: completion)
    }
    
    public func setNotifyValue(toEnabled enabled: Bool, ofCharac charac: CBCharacteristic, completion: @escaping UpdateNotificationStateCompletion) {
        setNotifyValue(toEnabled: enabled,
                            forCharacWithUUID: charac,
                            ofServiceWithUUID: charac.service,
                            completion: completion)
    }
}
