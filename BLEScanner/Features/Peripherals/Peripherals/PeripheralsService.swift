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
    func fetchPeripherals() -> Observable<(perhipherals: [Peripheral]?, error: BKError?)>
}

class PeripheralsService: PeripheralsFetching {
    
    private let centralManager: BKCentralManaging
    private var peripherals = [Peripheral]()
    
    init(centralManager: BKCentralManaging) {
        self.centralManager = centralManager
    }
    
    func fetchPeripherals() -> Observable<(perhipherals: [Peripheral]?, error: BKError?)> {
        return Observable.create { [unowned self] observer in
            self.centralManager.scanForPeripherals(withServiceUUIDs: nil, options: nil, timeoutAfter: 15) { scanResult in
                switch scanResult {
                case .scanStarted:
                    break
                case let .scanResult(peripheral, advertisementData, rssi):
                    if !self.peripherals.contains(where: {$0.bkPeripheral.identifier.uuidString == peripheral.identifier.uuidString}) {
                        self.peripherals.append(Peripheral(bkPeripheral: peripheral, advertismentData: advertisementData, rssi: rssi))
                        self.peripherals.sort(by: { $0.rssi ?? 127 > $1.rssi ?? 127 })
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
