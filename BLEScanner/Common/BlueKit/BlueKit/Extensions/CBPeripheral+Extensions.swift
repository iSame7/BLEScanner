//
//  CBPeripheral+Extensions.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import CoreBluetooth

public extension CBPeripheral {
    
    func serviceWithUUID(_ uuid: CBUUID) -> CBService? {
        guard let services = services else { return nil }
        
        return services.filter { $0.uuid == uuid }.first
    }
    
    func servicesWithUUIDs(_ servicesUUIDs: [CBUUID]) -> (foundServices: [CBService], missingServicesUUIDs: [CBUUID]) {
        guard let currentServices = services , !currentServices.isEmpty else {
            return (foundServices: [], missingServicesUUIDs: servicesUUIDs)
        }
        
        let currentServicesUUIDs = currentServices.map { $0.uuid }
        
        let currentServicesUUIDsSet = Set(currentServicesUUIDs)
        let requestedServicesUUIDsSet = Set(servicesUUIDs)
        
        let foundServicesUUIDsSet = requestedServicesUUIDsSet.intersection(currentServicesUUIDsSet)
        let missingServicesUUIDsSet = requestedServicesUUIDsSet.subtracting(currentServicesUUIDsSet)
        
        let foundServices = currentServices.filter { foundServicesUUIDsSet.contains($0.uuid) }
        
        return (foundServices: foundServices, missingServicesUUIDs: Array(missingServicesUUIDsSet))
    }
}
