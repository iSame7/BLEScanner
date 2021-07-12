//
//  CBCharacteristic.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import CoreBluetooth

public extension CBCharacteristic {
    
    func descriptorWithUUID(_ uuid: CBUUID) -> CBDescriptor? {
        guard let descriptors = descriptors else { return nil }
        
        return descriptors.filter { $0.uuid == uuid }.first
    }
    
    func descriptorsWithUUIDs(_ descriptorsUUIDs: [CBUUID]) -> (foundDescriptors: [CBDescriptor], missingDescriptorsUUIDs: [CBUUID]) {
        guard let currentDescriptors = self.descriptors , !currentDescriptors.isEmpty else {
            return (foundDescriptors: [], missingDescriptorsUUIDs: descriptorsUUIDs)
        }
        
        let currentDescriptorsUUIDs = currentDescriptors.map { $0.uuid }
        
        let currentDescriptorsUUIDsSet = Set(currentDescriptorsUUIDs)
        let requestedDescriptorsUUIDsSet = Set(descriptorsUUIDs)
        
        let foundDescriptorsUUIDsSet = requestedDescriptorsUUIDsSet.intersection(currentDescriptorsUUIDsSet)
        let missingDescriptorsUUIDsSet = requestedDescriptorsUUIDsSet.subtracting(currentDescriptorsUUIDsSet)
        
        let foundDescriptors = currentDescriptors.filter { foundDescriptorsUUIDsSet.contains($0.uuid) }
        
        return (foundDescriptors: foundDescriptors, missingDescriptorsUUIDs: Array(missingDescriptorsUUIDsSet))
    }
    
    func valueToString() -> String? {
        guard let value = self.value, let valueAsString = String(bytes: value, encoding: String.Encoding.utf8) else { return nil }
        
        return valueAsString
    }
    
    var name : String {
        guard let name = self.uuid.name else {
            return "0x" + self.uuid.uuidString
        }
        return name
    }
}
