//
//  CBService+Extensions.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 16/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import CoreBluetooth

public extension CBService {

    var name : String {
        guard let name = self.uuid.name else {
            return "UUID: " + self.uuid.uuidString
        }

        return name
    }
}
