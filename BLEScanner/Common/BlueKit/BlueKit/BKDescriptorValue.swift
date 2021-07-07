//
//  DescriptorValue.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//


import CoreBluetooth

/**
 Wrapper around common GATT descriptor values. Automatically unwrap and cast your descriptor values for
 standard GATT descriptor UUIDs.
 */

public enum DescriptorValue {
    case characteristicExtendedProperties(value: UInt16)
    case characteristicUserDescription(value: String)
    case clientCharacteristicConfigurationString(value: UInt16)
    case serverCharacteristicConfigurationString(value: UInt16)
    case characteristicFormatString(value: Data)
    case characteristicAggregateFormatString(value: UInt16)
    case customValue(value: AnyObject)
    
    init(descriptor: CBDescriptor) throws {
        guard let value = descriptor.value else {
            throw BKError.invalidDescriptorValue(descriptor: descriptor)
        }
        
        switch descriptor.uuidRepresentation.uuidString {
        case CBUUIDCharacteristicExtendedPropertiesString:
            guard let valueAsNSNumber = descriptor.value as? NSNumber, let value = UInt16(exactly: valueAsNSNumber) else {
                throw BKError.invalidDescriptorValue(descriptor: descriptor)
            }
            self = .characteristicExtendedProperties(value: value)
            
        case CBUUIDCharacteristicUserDescriptionString:
            guard let value = descriptor.value as? String else {
                throw BKError.invalidDescriptorValue(descriptor: descriptor)
            }
            self = .characteristicUserDescription(value: value)
            
        case CBUUIDClientCharacteristicConfigurationString:
            guard let valueAsNSNumber = descriptor.value as? NSNumber, let value = UInt16(exactly: valueAsNSNumber) else {
                throw BKError.invalidDescriptorValue(descriptor: descriptor)
            }
            self = .clientCharacteristicConfigurationString(value: value)
            
        case CBUUIDServerCharacteristicConfigurationString:
            guard let valueAsNSNumber = descriptor.value as? NSNumber, let value = UInt16(exactly: valueAsNSNumber) else {
                throw BKError.invalidDescriptorValue(descriptor: descriptor)
            }
            self = .serverCharacteristicConfigurationString(value: value)
            
        case CBUUIDCharacteristicFormatString:
            guard let value = descriptor.value as? Data else {
                throw BKError.invalidDescriptorValue(descriptor: descriptor)
            }
            self = .characteristicFormatString(value: value)
            
        case CBUUIDCharacteristicAggregateFormatString:
            guard let valueAsNSNumber = descriptor.value as? NSNumber, let value = UInt16(exactly: valueAsNSNumber) else {
                throw BKError.invalidDescriptorValue(descriptor: descriptor)
            }
            self = .characteristicAggregateFormatString(value: value)
            
        default:
            self = .customValue(value: value as AnyObject)
        }
    }
}
