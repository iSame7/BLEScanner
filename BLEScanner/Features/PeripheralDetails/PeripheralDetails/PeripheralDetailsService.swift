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
    
    private let peripheral: BKPeripheralBLECabable
    private var services = [Service]()
    private var discoverredServices = [CBService]()
    private var discoverredServicesIndex = 0
    
    init(peripheral: BKPeripheralBLECabable) {
        self.peripheral = peripheral
    }
    
    func fetchServices() -> Observable<(services: [Service]?, error: Error?)> {
        return Observable.create { [unowned self] observer in
//            self.peripheral.connect(withTimeout: nil) { [weak self] result in
//                guard let self = self else { return }
                
//                switch result {
//                case .success:
//                    print("You are now connected to the peripheral")
//
                    
                    self.peripheral.discoverServices(withUUIDs: nil) { result in
                        switch result {
                        case let .success(services):
                            print("Discovered Services: \(services)")
                            for service in services {
                                print("Service: \(service)")
                                self.peripheral.discoverCharacteristics(withUUIDs: nil, ofServiceWithUUID: service) { result in
                                    switch result {
                                    case let .success(characteristics):
                                        print("Discovered Characteristics for service: \(service.name), Characteristics: \(characteristics)")                                        
                                        let newCharacteristics = characteristics.map { characteristic -> Characteristic in
                                            let value = characteristic.valueToString()
                                            let propertiesAsString = characteristic.properties.names.joined(separator: " ")
                                            return Characteristic(name: characteristic.name, properties: "Properties: " + propertiesAsString, value: value)
                                        }
                                        
                                        self.services.append(Service(name: service.name, characteristics: newCharacteristics))
                                        observer.onNext((self.services, nil))
                                        
                                    case let .failure(error):
                                        print("Cannot discover characteristics for a service cause of: \(error)")
                                        observer.onNext((self.services, error))
                                    }
                                }
                            }
                        case let .failure(error):
                            print("Service discovery issue: \(error)")
                            observer.onNext((self.services, error))
                        }
                    }
                    
                    
                    
//                case .failure(let error):
//                    observer.onNext((self.services, error))
//                }
//            }
            return Disposables.create()
        }
    }
}
