//
//  PeripheralsServices.swift
//  Peripherals
//
//  Created by Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import RxSwift
import BlueKit
import Core

protocol PeripheralsFetching {
    func fetchPeripherals() -> Observable<(peripherals: [Peripheral]?, error: BKError?)>
}

class PeripheralsService: PeripheralsFetching {
    
    private let centralManager: BKCentralManaging
    private var peripherals = [Peripheral]()
    
    init(centralManager: BKCentralManaging) {
        self.centralManager = centralManager
    }
    
    func fetchPeripherals() -> Observable<(peripherals: [Peripheral]?, error: BKError?)> {
        return Observable.create { [unowned self] observer in
            self.centralManager.scanForPeripherals(withServiceUUIDs: nil, options: nil, timeoutAfter: 15) { scanResult in
                switch scanResult {
                case .scanStarted:
                    break
                case let .scanResult(bkPeripheral, advertisementData, rssi):
                    let peripheral = Peripheral(bkPeripheral: bkPeripheral)
                    if !peripherals.contains(peripheral) {
                        peripheral.rssi = rssi
                        peripheral.advertismentData = advertisementData
                        peripherals.append(peripheral)
                    } else {
                        guard let index = self.peripherals.firstIndex(of: peripheral) else {
                            return
                        }
                        
                        let originalPeripheral = peripherals[index]
                        let now = Date().timeIntervalSince1970
                        
                        // If the last update within one second, then ignore it
                        guard now - originalPeripheral.lastUpdatedTimeInterval >= 1.0 else {
                            return
                        }

                        originalPeripheral.rssi = rssi
                        originalPeripheral.advertismentData = advertisementData
                        originalPeripheral.lastUpdatedTimeInterval = now
                    }
                    
                    observer.onNext((self.peripherals, nil))
                case let .scanStopped(_, error):
                    observer.onNext((self.peripherals, error))
                }
            }
            return Disposables.create()
        }
    }
}
