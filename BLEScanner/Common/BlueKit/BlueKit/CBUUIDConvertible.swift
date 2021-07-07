//
//  CBUUIDConvertible.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import CoreBluetooth

public protocol CBUUIDConvertible {
    var uuidRepresentation: CBUUID { get }
}

extension String: CBUUIDConvertible {
    public var uuidRepresentation: CBUUID {
        return CBUUID(string: self)
    }
}

extension UUID: CBUUIDConvertible {
    public var uuidRepresentation: CBUUID {
        return CBUUID(nsuuid: self)
    }
}

extension CBUUID: CBUUIDConvertible {
    public var uuidRepresentation: CBUUID {
        return self
    }
}

extension CBAttribute: CBUUIDConvertible {
    public var uuidRepresentation: CBUUID {
        return self.uuid
    }
}

func extractCBUUIDs(_ uuidConvertibles: [CBUUIDConvertible]?) -> [CBUUID]? {
    guard let uuidConvertibles = uuidConvertibles , !uuidConvertibles.isEmpty else { return nil }
    
    return uuidConvertibles.map { $0.uuidRepresentation }
}
