//
//  PeripheralDetailsService.swift
//  PeripheralDetails
//
//  Created Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import RxSwift
import Core
import BlueKit
import CoreBluetooth

protocol PeripheralDetailsServiceFetching {
    func fetchServices() -> Observable<(services: [Service]?, error: Error?)>
}

class PeripheralDetailsService: PeripheralDetailsServiceFetching {
    
    private let bluetoothManager: BKBluetoothControlling
    private let peripheral: BKPeripheralBLECabable
    private var services = [Service]()
    private var discoverredServices = [CBService]()
    private var discoverredServicesIndex = 0
    private let disposeBag: DisposeBag = DisposeBag()

    init(bluetoothManager: BKBluetoothControlling, peripheral: BKPeripheralBLECabable) {
        self.bluetoothManager = bluetoothManager
        self.peripheral = peripheral
    }
    
    func fetchServices() -> Observable<(services: [Service]?, error: Error?)> {
        return Observable.create { [unowned self] observer in
            
            self.bluetoothManager.connectPeripheral(self.peripheral)
            
            (self.bluetoothManager as! BKBluetoothManager).rx.servicesDiscovered.subscribe(onNext: { peripheral in
                print("Discovered Services: \(String(describing: bluetoothManager.connectedPeripheral?.services))")
                self.bluetoothManager.discoverCharacteristics()
                (self.bluetoothManager as? BKBluetoothManager)?.rx.characteriticsDiscovered.subscribe({ event in
                    guard let element = event.element, let characteristics = element?.characteristics else {
                        return
                    }
                    let newCharacteristics = characteristics.map { characteristic -> Characteristic in
                        let value = characteristic.valueToString()
                        let propertiesAsString = characteristic.properties.names.joined(separator: " ")
                        return Characteristic(name: characteristic.name, properties: "Properties: " + propertiesAsString, value: value)
                    }
                    
                    self.services.append(Service(name: element?.name ?? "", characteristics: newCharacteristics))
                    observer.onNext((self.services, nil))
                }).disposed(by: self.disposeBag)
                
            }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
}
