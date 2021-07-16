//
//  BKBluetoothDelegate.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 15/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import CoreBluetooth

@objc public protocol BKBluetoothManagerDelegate: AnyObject {
    @objc optional func didUpdateState(_ state: CBManagerState)
    @objc optional func didDiscoverPeripheral(_ peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber)
    @objc optional func didConnectedPeripheral(_ connectedPeripheral: CBPeripheral)
    @objc optional func didFailToConnectPeripheral(_ peripheral: CBPeripheral, error: Error)
    @objc optional func didDiscoverServices(_ peripheral: CBPeripheral)
    @objc optional func didDisconnectPeripheral(_ peripheral: CBPeripheral)
    @objc optional func didFailedToInterrogate(_ peripheral: CBPeripheral)
    @objc optional func didDiscoverCharacteritics(_ service: CBService)
    @objc optional func didFailToDiscoverCharacteritics(_ error: Error)
    @objc optional func didDiscoverDescriptors(_ characteristic: CBCharacteristic)
    @objc optional func didFailToDiscoverDescriptors(_ error: Error)
    @objc optional func didReadValueForCharacteristic(_ characteristic: CBCharacteristic)
    @objc optional func didFailToReadValueForCharacteristic(_ error: Error)
}
