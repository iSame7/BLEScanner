//
//  BKPeripheralBLECabable.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 16/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import CoreBluetooth

public protocol BKPeripheralBLECabable {
    
    var identifier: UUID { get }
    var name: String? { get }
    var state: CBPeripheralState { get }
    var services: [CBService]? { get }
    
    func discoverServices(_ serviceUUIDs: [CBUUID]?)
    func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?, for service: CBService)
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService)
    func readValue(for characteristic: CBCharacteristic)
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType)
    func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic)
    func discoverDescriptors(for characteristic: CBCharacteristic)
    func readValue(for descriptor: CBDescriptor)
    func writeValue(_ data: Data, for descriptor: CBDescriptor)
}

extension CBPeripheral: BKPeripheralBLECabable {}

