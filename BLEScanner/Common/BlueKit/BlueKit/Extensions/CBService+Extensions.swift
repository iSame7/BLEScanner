//
//  CBService+Extensions.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import CoreBluetooth

public extension CBService {
    
    func characteristicWithUUID(_ uuid: CBUUID) -> CBCharacteristic? {
        guard let characteristics = characteristics else { return nil }
        
        return characteristics.filter { $0.uuid == uuid }.first
    }
    
    func characteristicsWithUUIDs(_ characteristicsUUIDs: [CBUUID]) -> (foundCharacteristics: [CBCharacteristic], missingCharacteristicsUUIDs: [CBUUID]) {
        guard let currentCharacteristics = characteristics , !currentCharacteristics.isEmpty else {
            return (foundCharacteristics: [], missingCharacteristicsUUIDs: characteristicsUUIDs)
        }
        
        let currentCharacteristicsUUID = currentCharacteristics.map { $0.uuid }
        
        let currentCharacteristicsUUIDSet = Set(currentCharacteristicsUUID)
        let requestedCharacteristicsUUIDSet = Set(characteristicsUUIDs)
        
        let foundCharacteristicsUUIDSet = requestedCharacteristicsUUIDSet.intersection(currentCharacteristicsUUIDSet)
        let missingCharacteristicsUUIDSet = requestedCharacteristicsUUIDSet.subtracting(currentCharacteristicsUUIDSet)
        
        let foundCharacteristics = currentCharacteristics.filter { foundCharacteristicsUUIDSet.contains($0.uuid) }
        
        return (foundCharacteristics: foundCharacteristics, missingCharacteristicsUUIDs: Array(missingCharacteristicsUUIDSet))
    }
    
    var name : String {
        guard let name = self.uuid.name else {
            return "UUID: " + self.uuid.uuidString
        }
        
        return name
    }
}
