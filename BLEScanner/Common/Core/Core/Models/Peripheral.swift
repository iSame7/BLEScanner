//
//  Peripheral.swift
//  Core
//
//  Created by Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import BlueKit
import CoreBluetooth

public class Peripheral: Equatable, Hashable {
    
    public let bkPeripheral: CBPeripheral
    public var advertismentData: [String: Any] = [:]
    public var rssi: Int = 0
    public var lastUpdatedTimeInterval: TimeInterval

    public init(bkPeripheral: CBPeripheral) {
        self.bkPeripheral = bkPeripheral
        self.lastUpdatedTimeInterval = Date().timeIntervalSince1970
    }
    
    public static func == (lhs: Peripheral, rhs: Peripheral) -> Bool {
        return lhs.bkPeripheral.identifier.uuidString.isEqual(rhs.bkPeripheral.identifier.uuidString)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(bkPeripheral.hash)
    }
}
