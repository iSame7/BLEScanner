//
//  ConnectPeripheralRequest.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 06/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import CoreBluetooth

final class PeripheralRequest {
    
    var connectPeripheralcompletions: [ConnectPeripheralCompletion] = []
    var disconnectPeripheralcompletions: [ConnectPeripheralCompletion] = []
    let peripheral: CBPeripheral
    
    init(peripheral: CBPeripheral, connectPeripheralcompletion: @escaping ConnectPeripheralCompletion) {
        self.connectPeripheralcompletions.append(connectPeripheralcompletion)
        self.peripheral = peripheral
    }
    
    init(peripheral: CBPeripheral, disconnectPeripheralcompletion: @escaping DisconnectPeripheralCompletion) {
        self.disconnectPeripheralcompletions.append(disconnectPeripheralcompletion)
        self.peripheral = peripheral
    }
    
    func invokeConnectPeripheralCompletions(error: Error?) {
        let result: Result<Void, Error> = {
            if let error = error {
                return .failure(error)
            } else {
                return .success(())
            }
        }()
        
        connectPeripheralcompletions.forEach { completion in
            completion(result)
        }
    }
    
    func invokeDisconnectPeripheralCompletions(error: Error?) {
        let result: Result<Void, Error> = {
            if let error = error {
                return .failure(error)
            } else {
                return .success(())
            }
        }()
        
        disconnectPeripheralcompletions.forEach { completion in
            completion(result)
        }
    }
}
