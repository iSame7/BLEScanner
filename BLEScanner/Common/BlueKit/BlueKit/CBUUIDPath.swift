//
//  CBUUIDPath.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import CoreBluetooth

func ==(lhs: CBUUIDPath, rhs: CBUUIDPath) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

struct CBUUIDPath: Hashable {
    let hash: Int
    
    init(uuids: CBUUID...) {
        var stringPath: String = String()
        
        for uuid in uuids {
            stringPath.append(uuid.uuidString)
        }
        
        self.hash = stringPath.hashValue
    }
    
}

extension CBService {
    
    var uuidPath: CBUUIDPath {
        return servicePath(service: self)
    }
    
    func servicePath(service: CBUUIDConvertible) -> CBUUIDPath {
        return CBUUIDPath(uuids: service.uuidRepresentation)
    }
}

extension CBCharacteristic {
    
    var uuidPath: CBUUIDPath {
        return characteristicPath(service: self.service, characteristic: self)
    }
    

    func characteristicPath(service: CBUUIDConvertible,
                            characteristic: CBUUIDConvertible) -> CBUUIDPath {
        return CBUUIDPath(uuids: service.uuidRepresentation,
                          characteristic.uuidRepresentation)
    }
}

extension CBDescriptor {
    
    var uuidPath: CBUUIDPath {
        return descriptorPath(service: self.characteristic.service, characteristic: self.characteristic, descriptor: self)
    }
    

    func descriptorPath(service: CBUUIDConvertible,
                        characteristic: CBUUIDConvertible,
                        descriptor: CBUUIDConvertible) -> CBUUIDPath {
        return CBUUIDPath(uuids: service.uuidRepresentation,
                          characteristic.uuidRepresentation,
                          descriptor.uuidRepresentation)
    }
}
