//
//  BKError.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 06/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import CoreBluetooth

public enum BKError: Error {
    
    public enum BKBluetoothUnavailbleFailureReason {
        case unsupported
        case unauthorized
        case poweredOff
        case unknown
    }
    
    public enum BKOperation: String {
        case connectPeripheral = "Connect peripheral"
        case disconnectPeripheral = "Disconnect peripheral"
        case readRSSI = "Read RSSI"
        case discoverServices = "Discover services"
        case discoverIncludedServices = "Discover included services"
        case discoverCharacteristics = "Discover characteristics"
        case discoverDescriptors = "Discover descriptors"
        case readCharacteristic = "Read characteristic"
        case readDescriptor = "Read descriptor"
        case writeCharacteristic = "Write characteristic"
        case writeDescriptor = "Write descriptor"
        case updateNotificationStatus = "Update notification status"
    }
    
    case bluetoothUnavailable(reason: BKBluetoothUnavailbleFailureReason)
    case scanningEndedUnexpectedly
    case operationTimedOut(operation: BKOperation)
    case invalidPeripheral
    case peripheralFailedToConnectReasonUnknown
    case peripheralServiceNotFound(missingServicesUUIDs: [CBUUID])
    case peripheralCharacteristicNotFound(missingCharacteristicsUUIDs: [CBUUID])
    case peripheralDescriptorsNotFound(missingDescriptorsUUIDs: [CBUUID])
    case invalidDescriptorValue(descriptor: CBDescriptor)
}

extension BKError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .bluetoothUnavailable(let reason):
            return reason.localizedDescription
        case .scanningEndedUnexpectedly:
            return "Your peripheral scan ended unexpectedly."
        case .operationTimedOut(let operation):
            return "Bluetooth operation timed out: \(operation.rawValue)"
        case .invalidPeripheral:
            return "Invalid Bluetooth peripheral, you must rediscover this peripheral to use it again."
        case .peripheralFailedToConnectReasonUnknown:
            return "Failed to connect to your peripheral for an unknown reason."
        case .peripheralServiceNotFound(let missingUUIDs):
            let missingUUIDsString = missingUUIDs.map { $0.uuidString }.joined(separator: ",")
            return "Peripheral service(s) not found: \(missingUUIDsString)"
        case .peripheralCharacteristicNotFound(let missingUUIDs):
            let missingUUIDsString = missingUUIDs.map { $0.uuidString }.joined(separator: ",")
            return "Peripheral charac(s) not found: \(missingUUIDsString)"
        case .peripheralDescriptorsNotFound(let missingUUIDs):
            let missingUUIDsString = missingUUIDs.map { $0.uuidString }.joined(separator: ",")
            return "Peripheral descriptor(s) not found: \(missingUUIDsString)"
        case .invalidDescriptorValue(let descriptor):
            return "Failed to parse value for descriptor with uuid: \(descriptor.uuid.uuidString)"
        }
    }
}

extension BKError.BKBluetoothUnavailbleFailureReason {
    public var localizedDescription: String {
        switch self {
        case .unsupported:
            return "Your iOS device does not support Bluetooth."
        case .unauthorized:
            return "Unauthorized to use Bluetooth."
        case .poweredOff:
            return "Bluetooth is disabled, enable bluetooth and try again."
        case .unknown:
            return "Bluetooth is currently unavailable (unknown reason)."
        }
    }
}
