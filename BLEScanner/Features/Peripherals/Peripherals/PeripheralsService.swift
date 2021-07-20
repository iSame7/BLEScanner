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
import CoreBluetooth

protocol PeripheralsFetching {
    func fetchBluetoothState() ->  Observable<CBManagerState?>
    func fetchPeripherals() -> Observable<[Peripheral]?>
    func sortPeripherals() -> Observable<[Peripheral]>
    func stopFetchingPeripherals()
    func disconnectPeripheral()
}

class PeripheralsService: PeripheralsFetching {
    
    private let bluetoothManager: BKBluetoothControlling
    private var peripherals = [Peripheral]()
    private let disposeBag: DisposeBag = DisposeBag()
    
    init(bluetoothManager: BKBluetoothControlling) {
        self.bluetoothManager = bluetoothManager
    }
    
    func fetchBluetoothState() -> Observable<CBManagerState?> {
        return Observable.create { [unowned self] observer in
            
            (self.bluetoothManager as! BKBluetoothManager).rx.stateUpdated.subscribe(onNext: { state in
                observer.onNext(state)
            }).disposed(by: disposeBag)
            
            return Disposables.create()
        }
    }
    
    func fetchPeripherals() -> Observable<[Peripheral]?> {
        peripherals = [Peripheral]()
        self.bluetoothManager.scanForPeripherals()
        
        return (self.bluetoothManager as! BKBluetoothManager).rx.peripheralDiscovered.map { (peripheral, advertisementData, rssi) in
            let peripheral = Peripheral(bkPeripheral: peripheral)
            if !self.peripherals.contains(peripheral) {
                peripheral.rssi = Int(truncating: rssi)
                peripheral.advertismentData = advertisementData
                self.peripherals.append(peripheral)
            } else {
                guard let index = self.peripherals.firstIndex(of: peripheral) else {
                    return []
                }
                
                let originalPeripheral = self.peripherals[index]
                let now = Date().timeIntervalSince1970
                
                // If the last update within one second, then ignore it
                guard now - originalPeripheral.lastUpdatedTimeInterval >= 1.0 else {
                    return []
                }
                
                originalPeripheral.rssi = Int(truncating: rssi)
                originalPeripheral.advertismentData = advertisementData
                originalPeripheral.lastUpdatedTimeInterval = now
            }
            
            return self.peripherals
        }
    }
    
    func sortPeripherals() -> Observable<[Peripheral]> {
        return Observable.create { [unowned self] observer in
            self.peripherals = self.peripherals.filter({ pripheral in
                guard pripheral.rssi != 127 else {
                    return false
                }
                
                return true
            }).sorted(by: {$0.rssi > $1.rssi})
            observer.onNext((self.peripherals))
            return Disposables.create()
        }
    }
    
    func disconnectPeripheral() {
        bluetoothManager.disconnectPeripheral()
    }
    
    func stopFetchingPeripherals() {
        bluetoothManager.stopScanForPeripherals()
    }
}
