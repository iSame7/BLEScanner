//
//  CBCharacteristic.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import CoreBluetooth

public extension CBCharacteristic {

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

