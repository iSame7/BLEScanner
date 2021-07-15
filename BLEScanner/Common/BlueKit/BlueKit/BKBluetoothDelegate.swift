//
//  BKBluetoothDelegate.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 15/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import CoreBluetooth

public protocol BKBluetoothManagerDelegate: AnyObject {
    func didUpdateState(_ state: CBManagerState)
    func didDiscoverPeripheral(_ peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber)
    func didConnectedPeripheral(_ connectedPeripheral: CBPeripheral)
    func didFailToConnectPeripheral(_ peripheral: CBPeripheral, error: Error)
    func didDiscoverServices(_ peripheral: CBPeripheral)
    func didDisconnectPeripheral(_ peripheral: CBPeripheral)
    func didFailedToInterrogate(_ peripheral: CBPeripheral)
    func didDiscoverCharacteritics(_ service: CBService)
    func didFailToDiscoverCharacteritics(_ error: Error)
    func didDiscoverDescriptors(_ characteristic: CBCharacteristic)
    func didFailToDiscoverDescriptors(_ error: Error)
    func didReadValueForCharacteristic(_ characteristic: CBCharacteristic)
    func didFailToReadValueForCharacteristic(_ error: Error)
}

public extension BKBluetoothManagerDelegate {
    
    func didUpdateState(_ state: CBManagerState) {}
    
    func didDiscoverPeripheral(_ peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber) {}
    
    func didConnectedPeripheral(_ connectedPeripheral: CBPeripheral) {}
     
    func didFailToConnectPeripheral(_ peripheral: CBPeripheral, error: Error) {}
    
    func didDiscoverServices(_ peripheral: CBPeripheral) {}
    
    func didDisconnectPeripheral(_ peripheral: CBPeripheral) {}
    
    func didFailedToInterrogate(_ peripheral: CBPeripheral) {}
    
    func didDiscoverCharacteritics(_ service: CBService) {}
    
    func didFailToDiscoverCharacteritics(_ error: Error) {}
    
    func didDiscoverDescriptors(_ characteristic: CBCharacteristic) {}
    
    func didFailToDiscoverDescriptors(_ error: Error) {}
    
    func didReadValueForCharacteristic(_ characteristic: CBCharacteristic) {}
    
    func didFailToReadValueForCharacteristic(_ error: Error) {}
}
