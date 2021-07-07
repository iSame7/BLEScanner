//
//  Peripheral.swift
//  Core
//
//  Created by Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import BlueKit

public struct Peripheral {
    public let bkPeripheral: BKPeripheral
    public let advertismentData: [String: Any]
    public let rssi: Int?
    
    public init(bkPeripheral: BKPeripheral, advertismentData: [String: Any], rssi: Int?) {
        self.bkPeripheral = bkPeripheral
        self.advertismentData = advertismentData
        self.rssi = rssi
    }
}
