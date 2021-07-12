//
//  BKPeripheralProxy.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import CoreBluetooth

final class BKPeripheralProxy: NSObject  {
    
    private static let defaultTimeout: TimeInterval = 10
    
    private lazy var readRSSIRequests: [ReadRSSIRequest] = []
    private lazy var serviceRequests: [ServiceRequest] = []
    private lazy var includedServicesRequests: [IncludedServicesRequest] = []
    private lazy var characteristicRequests: [CharacteristicRequest] = []
    private lazy var descriptorRequests: [DescriptorRequest] = []
    private lazy var readCharacteristicRequests: [CBUUIDPath: [ReadCharacteristicRequest]] = [:]
    private lazy var readDescriptorRequests: [CBUUIDPath: [ReadDescriptorRequest]] = [:]
    private lazy var writeCharacteristicValueRequests: [CBUUIDPath: [WriteCharacteristicValueRequest]] = [:]
    private lazy var writeDescriptorValueRequests: [CBUUIDPath: [WriteDescriptorValueRequest]] = [:]
    private lazy var updateNotificationStateRequests: [CBUUIDPath: [UpdateNotificationStateRequest]] = [:]
    
    private weak var peripheral: BKPeripheral?
    
    private(set) var cbPeripheral: CBPeripheral
    
    // Peripheral that are no longer valid must be rediscovered again (happens when for example the Bluetooth is turned off
    // from a user's phone and turned back on
    private var valid: Bool = true
    
    init(cbPeripheral: CBPeripheral, peripheral: BKPeripheral) {
        self.cbPeripheral = cbPeripheral
        self.peripheral = peripheral
        
        super.init()
        
        cbPeripheral.delegate = self
        
        NotificationCenter.default.addObserver(forName: Notification.Name(BKCentral.Notifications.centralCBPeripheralDisconnected.rawValue),
                                               object: BKCentral.shared,
                                               queue: nil)
        { [weak self] (notification) in
            if let identifier = notification.userInfo?["identifier"] as? UUID, identifier == self?.cbPeripheral.identifier {
                self?.postPeripheralEvent(BKPeripheral.peripheralDisconnected, userInfo: notification.userInfo)
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(BKCentral.Notifications.centralStateChange.rawValue),
                                               object: BKCentral.shared,
                                               queue: nil)
        { [weak self] (notification) in
            if let state = notification.userInfo?["state"] as? CBManagerState, state == .poweredOff {
                self?.valid = false
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func postPeripheralEvent(_ event: Notification.Name, userInfo: [AnyHashable: Any]?) {
        guard let peripheral = self.peripheral else {
            return
        }
        
        NotificationCenter.default.post(
            name: event,
            object: peripheral,
            userInfo: userInfo
        )
    }
}

// MARK: Connect/Disconnect Requests

extension BKPeripheralProxy {
    
    func connect(timeout: TimeInterval = 10, _ completion: @escaping ConnectPeripheralCompletion) {
        if self.valid {
            BKCentral.shared.connect(peripheral: cbPeripheral, timeout: timeout, completion: completion)
        } else {
            completion(.failure(BKError.invalidPeripheral))
        }
    }
    
    func disconnect(_ completion: @escaping DisconnectPeripheralCompletion) {
        BKCentral.shared.disconnect(peripheral: cbPeripheral, completion: completion)
    }
}

// MARK: RSSI Requests
private final class ReadRSSIRequest {
    let Completion: ReadRSSIRequestCompletion
    
    init(Completion: @escaping ReadRSSIRequestCompletion) {
        self.Completion = Completion
    }
}

extension BKPeripheralProxy {
    
    func readRSSI(_ completion: @escaping ReadRSSIRequestCompletion) {
        connect { [weak self] result in
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            
            let request = ReadRSSIRequest(Completion: completion)
            self.readRSSIRequests.append(request)
            
            if self.readRSSIRequests.count == 1 {
                self.runRSSIRequest()
            }
        }
    }
    
    private func runRSSIRequest() {
        guard let request = readRSSIRequests.first else { return }
        
        cbPeripheral.readRSSI()
        Timer.scheduledTimer(
            timeInterval: BKPeripheralProxy.defaultTimeout,
            target: self,
            selector: #selector(self.readRSSIOperation),
            userInfo: request,
            repeats: false)
    }
    
    @objc private func readRSSIOperation(_ timer: Timer) {
        defer { if timer.isValid { timer.invalidate() } }
                
        guard let request = timer.userInfo as? ReadRSSIRequest else { return }
        
        if !readRSSIRequests.isEmpty {
            readRSSIRequests.removeFirst()
        }
        
        request.Completion(.failure(BKError.operationTimedOut(operation: .readRSSI)))
        
        runRSSIRequest()
    }
}

// MARK: Service requests
private final class ServiceRequest {
    let serviceUUIDs: [CBUUID]?
    
    let Completion: ServiceRequestCompletion
    
    init(serviceUUIDs: [CBUUID]?, Completion: @escaping ServiceRequestCompletion) {
        self.Completion = Completion
        
        if let serviceUUIDs = serviceUUIDs {
            self.serviceUUIDs = serviceUUIDs
        } else {
            self.serviceUUIDs = nil
        }
    }
}

extension BKPeripheralProxy {
    func discoverServices(_ serviceUUIDs: [CBUUID]?, completion: @escaping ServiceRequestCompletion) {
        connect { [weak self] result in
            guard let self = self else { return }

            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            
            // Checking if the peripheral has already discovered the services requested
            if let serviceUUIDs = serviceUUIDs {
                let servicesTuple = self.cbPeripheral.servicesWithUUIDs(serviceUUIDs)
                
                if servicesTuple.missingServicesUUIDs.count == 0 {
                    completion(.success(servicesTuple.foundServices))
                    return
                }
            }
            
            let request = ServiceRequest(serviceUUIDs: serviceUUIDs) { result in
                completion(result)
            }
            
            self.serviceRequests.append(request)
            
            if self.serviceRequests.count == 1 {
                self.runServiceRequest()
            }
        }
    }
    
    private func runServiceRequest() {
        guard let request = serviceRequests.first else { return }
        
        cbPeripheral.discoverServices(request.serviceUUIDs)
        
        Timer.scheduledTimer(
            timeInterval: BKPeripheralProxy.defaultTimeout,
            target: self,
            selector: #selector(self.serviceRequestTimout),
            userInfo: request,
            repeats: false)
    }
    
    @objc private func serviceRequestTimout(_ timer: Timer) {
        defer { if timer.isValid { timer.invalidate() } }

        guard let request = timer.userInfo as? ServiceRequest else { return }
        
        if !serviceRequests.isEmpty {
            serviceRequests.removeFirst()
        }
        
        request.Completion(.failure(BKError.operationTimedOut(operation: .discoverServices)))
        
        runServiceRequest()
    }
}

// MARK: Included services Request
private final class IncludedServicesRequest {
    let serviceUUIDs: [CBUUID]?
    let parentService: CBService
    
    let Completion: ServiceRequestCompletion
    
    init(serviceUUIDs: [CBUUID]?, forService service: CBService, Completion: @escaping ServiceRequestCompletion) {
        self.Completion = Completion
        
        if let serviceUUIDs = serviceUUIDs {
            self.serviceUUIDs = serviceUUIDs
        } else {
            self.serviceUUIDs = nil
        }
        
        self.parentService = service
    }
}

extension BKPeripheralProxy {
    func discoverIncludedServices(_ serviceUUIDs: [CBUUID]?, forService serviceUUID: CBUUID, completion: @escaping ServiceRequestCompletion) {
        discoverServices([serviceUUID]) { [weak self] result in
            guard let self = self else { return }

            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            
            guard case .success(let services) = result, let service = services.first else { return }
            
            let request = IncludedServicesRequest(serviceUUIDs: serviceUUIDs, forService: service) { result in
                completion(result)
            }
            
            self.includedServicesRequests.append(request)
            
            if self.includedServicesRequests.count == 1 {
                self.runIncludedServicesRequest()
            }
        }
    }
    
    private func runIncludedServicesRequest() {
        guard let request = includedServicesRequests.first else { return }
        
        cbPeripheral.discoverIncludedServices(request.serviceUUIDs, for: request.parentService)
        
        Timer.scheduledTimer(
            timeInterval: BKPeripheralProxy.defaultTimeout,
            target: self,
            selector: #selector(self.includedServicesRequestTimeout),
            userInfo: request,
            repeats: false)
    }
    
    @objc private func includedServicesRequestTimeout(_ timer: Timer) {
        defer { if timer.isValid { timer.invalidate() } }
        
        guard let request = timer.userInfo as? IncludedServicesRequest else { return }
        
        if !includedServicesRequests.isEmpty {
            includedServicesRequests.removeFirst()
        }
        
        request.Completion(.failure(BKError.operationTimedOut(operation: .discoverIncludedServices)))
        
        runIncludedServicesRequest()
    }
}

// MARK: Discover Characteristic requests
private final class CharacteristicRequest{
    let service: CBService
    let characteristicUUIDs: [CBUUID]?
    
    let Completion: CharacteristicRequestCompletion
    
    init(service: CBService,
         characteristicUUIDs: [CBUUID]?,
         Completion: @escaping CharacteristicRequestCompletion)
    {
        self.Completion = Completion
        
        self.service = service
        
        if let characteristicUUIDs = characteristicUUIDs {
            self.characteristicUUIDs = characteristicUUIDs
        } else {
            self.characteristicUUIDs = nil
        }
    }
    
}

extension BKPeripheralProxy {
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?,
                                 forService serviceUUID: CBUUID,
                                            completion: @escaping CharacteristicRequestCompletion) {
        discoverServices([serviceUUID]) { [weak self] result in
            guard let self = self else { return }

            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            
            
            guard case .success(let services) = result, let service = services.first else { return }
            
            
            if let characteristicUUIDs = characteristicUUIDs {
                let characTuple = service.characteristicsWithUUIDs(characteristicUUIDs)
                
                if (characTuple.missingCharacteristicsUUIDs.isEmpty) {
                    completion(.success(characTuple.foundCharacteristics))
                    return
                }
            }
            
            let request = CharacteristicRequest(service: service,
                                                characteristicUUIDs: characteristicUUIDs) { result in
                completion(result)
            }
            
            self.characteristicRequests.append(request)
            
            if self.characteristicRequests.count == 1 {
                self.runCharacteristicRequest()
            }
        }
    }
    
    private func runCharacteristicRequest() {
        guard let request = self.characteristicRequests.first else { return }
        
        cbPeripheral.discoverCharacteristics(request.characteristicUUIDs, for: request.service)
        
        Timer.scheduledTimer(
            timeInterval: BKPeripheralProxy.defaultTimeout,
            target: self,
            selector: #selector(characteristicRequestTimeout),
            userInfo: request,
            repeats: false)
    }
    
    @objc private func characteristicRequestTimeout(_ timer: Timer) {
        defer { if timer.isValid { timer.invalidate() } }

        guard let request = timer.userInfo as? CharacteristicRequest else { return }
        
        if !characteristicRequests.isEmpty {
            characteristicRequests.removeFirst()
        }
        
        request.Completion(.failure(BKError.operationTimedOut(operation: .discoverCharacteristics)))
        
        runCharacteristicRequest()
    }
}

// MARK: Discover Descriptors requests

private final class DescriptorRequest {
    let service: CBService
    let characteristic: CBCharacteristic
    
    let Completion: DescriptorRequestCompletion
    
    init(characteristic: CBCharacteristic, Completion: @escaping DescriptorRequestCompletion) {
        self.Completion = Completion
        
        self.service = characteristic.service
        self.characteristic = characteristic
    }
}

extension BKPeripheralProxy {
    func discoverDescriptorsForCharacteristic(_ characteristicUUID: CBUUID, serviceUUID: CBUUID, completion: @escaping DescriptorRequestCompletion) {
        discoverCharacteristics([characteristicUUID], forService: serviceUUID) { [weak self] result in
            guard let self = self else { return }

            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            
            
            guard case .success(let characteristics) = result, let characteristic = characteristics.first else { return }
            
            let request = DescriptorRequest(characteristic: characteristic) { result in
                completion(result)
            }
            
            self.descriptorRequests.append(request)
            
            if self.descriptorRequests.count == 1 {
                self.runDescriptorRequest()
            }
        }
    }
    
    private func runDescriptorRequest() {
        guard let request = self.descriptorRequests.first else {
            return
        }
        
        cbPeripheral.discoverDescriptors(for: request.characteristic)
        
        Timer.scheduledTimer(
            timeInterval: BKPeripheralProxy.defaultTimeout,
            target: self,
            selector: #selector(self.descriptorRequestTimeout),
            userInfo: request,
            repeats: false)
    }
    
    @objc private func descriptorRequestTimeout(_ timer: Timer) {
        defer { if timer.isValid { timer.invalidate() } }
        
        guard let request = timer.userInfo as? DescriptorRequest else { return }
        
        if !descriptorRequests.isEmpty {
            descriptorRequests.removeFirst()
        }
        
        request.Completion(.failure(BKError.operationTimedOut(operation: .discoverDescriptors)))
        
        runDescriptorRequest()
    }
}

// MARK: Read Characteristic value requests

private final class ReadCharacteristicRequest {
    let service: CBService
    let characteristic: CBCharacteristic
    
    let Completion: ReadCharacRequestCompletion
    
    init(characteristic: CBCharacteristic, Completion: @escaping ReadCharacRequestCompletion) {
        self.Completion = Completion
        self.service = characteristic.service
        self.characteristic = characteristic
    }
    
}

extension BKPeripheralProxy {
    func readCharacteristic(_ characteristicUUID: CBUUID,
                            serviceUUID: CBUUID,
                            completion: @escaping ReadCharacRequestCompletion) {
        discoverCharacteristics([characteristicUUID], forService: serviceUUID) { [weak self] result in
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            
            
            guard case .success(let characteristics) = result, let characteristic = characteristics.first else { return }
            
            let request = ReadCharacteristicRequest(characteristic: characteristic) { result in
                completion(result)
            }
            
            let readPath = characteristic.uuidPath
            
            if var currentPathRequests = self.readCharacteristicRequests[readPath] {
                currentPathRequests.append(request)
                self.readCharacteristicRequests[readPath] = currentPathRequests
            } else {
                self.readCharacteristicRequests[readPath] = [request]
                
                self.runReadCharacteristicRequest(readPath)
            }
        }
    }
    
    private func runReadCharacteristicRequest(_ readPath: CBUUIDPath) {
        guard let request = readCharacteristicRequests[readPath]?.first else { return }
        
        cbPeripheral.readValue(for: request.characteristic)
        
        Timer.scheduledTimer(
            timeInterval: BKPeripheralProxy.defaultTimeout,
            target: self,
            selector: #selector(self.readCharacteristicTimeout),
            userInfo: request,
            repeats: false)
    }
    
    @objc private func readCharacteristicTimeout(_ timer: Timer) {
        defer { if timer.isValid { timer.invalidate() } }
        
        guard let request = timer.userInfo as? ReadCharacteristicRequest else { return }
        
        let readPath = request.characteristic.uuidPath
        
        readCharacteristicRequests[readPath]?.removeFirst()
        if readCharacteristicRequests[readPath]?.count == 0 {
            readCharacteristicRequests[readPath] = nil
        }
        
        request.Completion(.failure(BKError.operationTimedOut(operation: .readCharacteristic)))
        
        runReadCharacteristicRequest(readPath)
    }
}

// MARK: Read Descriptor value requests

private final class ReadDescriptorRequest {
    let service: CBService
    let characteristic: CBCharacteristic
    let descriptor: CBDescriptor
    
    let Completion: ReadDescriptorRequestCompletion
    
    init(descriptor: CBDescriptor, Completion: @escaping ReadDescriptorRequestCompletion) {
        self.Completion = Completion
        
        self.descriptor = descriptor
        self.characteristic = descriptor.characteristic
        self.service = descriptor.characteristic.service
    }
    
}

extension BKPeripheralProxy {
    func readDescriptor(_ descriptorUUID: CBUUID,
                        characteristicUUID: CBUUID,
                        serviceUUID: CBUUID,
                        completion: @escaping ReadDescriptorRequestCompletion) {
        
        discoverDescriptorsForCharacteristic(characteristicUUID, serviceUUID: serviceUUID) { [weak self]result in
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            
            
            guard case .success(let descriptors) = result, let descriptor = descriptors.first else { return }
            
            let request = ReadDescriptorRequest(descriptor: descriptor, Completion: completion)
            
            let readPath = descriptor.uuidPath
            
            if var currentPathRequests = self.readDescriptorRequests[readPath] {
                currentPathRequests.append(request)
                self.readDescriptorRequests[readPath] = currentPathRequests
            } else {
                self.readDescriptorRequests[readPath] = [request]
                
                self.runReadDescriptorRequest(readPath)
            }
        }
    }
    
    private func runReadDescriptorRequest(_ readPath: CBUUIDPath) {
        guard let request = self.readDescriptorRequests[readPath]?.first else {
            return
        }
        
        self.cbPeripheral.readValue(for: request.descriptor)
        
        Timer.scheduledTimer(
            timeInterval: BKPeripheralProxy.defaultTimeout,
            target: self,
            selector: #selector(self.readDescriptorTimeout),
            userInfo: request,
            repeats: false)
    }
    
    @objc private func readDescriptorTimeout(_ timer: Timer) {
        defer { if timer.isValid { timer.invalidate() } }
        
        guard let request = timer.userInfo as? ReadDescriptorRequest else { return }
        
        let readPath = request.descriptor.uuidPath
        
        readDescriptorRequests[readPath]?.removeFirst()
        if readDescriptorRequests[readPath]?.count == 0 {
            readDescriptorRequests[readPath] = nil
        }
        
        request.Completion(.failure(BKError.operationTimedOut(operation: .readDescriptor)))
        
        runReadDescriptorRequest(readPath)
    }
}

// MARK: Write Characteristic value requests
private final class WriteCharacteristicValueRequest {
    let service: CBService
    let characteristic: CBCharacteristic
    let value: Data
    let type: CBCharacteristicWriteType
    
    let Completion: WriteRequestCompletion
    
    init(characteristic: CBCharacteristic, value: Data, type: CBCharacteristicWriteType, Completion: @escaping WriteRequestCompletion) {
        self.Completion = Completion
        self.value = value
        self.type = type
        self.characteristic = characteristic
        self.service = characteristic.service
    }
    
}

extension BKPeripheralProxy {
    func writeCharacteristicValue(_ characteristicUUID: CBUUID,
                                  serviceUUID: CBUUID,
                                  value: Data,
                                  type: CBCharacteristicWriteType,
                                  completion: @escaping WriteRequestCompletion)
    {
        discoverCharacteristics([characteristicUUID], forService: serviceUUID) { [weak self] result in
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            
            
            guard case .success(let characteristics) = result, let characteristic = characteristics.first else { return }

            let request = WriteCharacteristicValueRequest(characteristic: characteristic,
                                                          value: value,
                                                          type: type) { result in
                completion(result)
            }
            
            let writePath = characteristic.uuidPath
            
            if var currentPathRequests = self.writeCharacteristicValueRequests[writePath] {
                currentPathRequests.append(request)
                self.writeCharacteristicValueRequests[writePath] = currentPathRequests
            } else {
                self.writeCharacteristicValueRequests[writePath] = [request]
                
                self.runWriteCharacteristicValueRequest(writePath)
            }
        }
    }
    
    private func runWriteCharacteristicValueRequest(_ writePath: CBUUIDPath) {
        guard let request = writeCharacteristicValueRequests[writePath]?.first else { return }
        
        cbPeripheral.writeValue(request.value, for: request.characteristic, type: request.type)
        
        if request.type == CBCharacteristicWriteType.withResponse {
            Timer.scheduledTimer(
                timeInterval: BKPeripheralProxy.defaultTimeout,
                target: self,
                selector: #selector(writeCharacteristicValueRequestTimeout),
                userInfo: request,
                repeats: false)
        } else {
            // If no response is expected, we execute the Completion and clear the request right away
            self.writeCharacteristicValueRequests[writePath]?.removeFirst()
            if self.writeCharacteristicValueRequests[writePath]?.count == 0 {
                self.writeCharacteristicValueRequests[writePath] = nil
            }
            
            request.Completion(.success(()))
            
            self.runWriteCharacteristicValueRequest(writePath)
        }
        
    }
    
    @objc private func writeCharacteristicValueRequestTimeout(_ timer: Timer) {
        defer { if timer.isValid { timer.invalidate() } }
        
        guard let request = timer.userInfo as? WriteCharacteristicValueRequest else { return }
        
        let writePath = request.characteristic.uuidPath
        
        writeCharacteristicValueRequests[writePath]?.removeFirst()
        if writeCharacteristicValueRequests[writePath]?.isEmpty ?? false {
            writeCharacteristicValueRequests[writePath] = nil
        }
        
        request.Completion(.failure(BKError.operationTimedOut(operation: .writeCharacteristic)))
            
        runWriteCharacteristicValueRequest(writePath)
    }
}

// MARK: Write Descriptor value requests

private final class WriteDescriptorValueRequest {
    let service: CBService
    let characteristic: CBCharacteristic
    let descriptor: CBDescriptor
    let value: Data
    
    let Completion: WriteRequestCompletion
    
    init(descriptor: CBDescriptor, value: Data, Completion: @escaping WriteRequestCompletion) {
        self.Completion = Completion
        self.value = value
        self.descriptor = descriptor
        self.characteristic = descriptor.characteristic
        self.service = descriptor.characteristic.service
    }
}

extension BKPeripheralProxy {
    
    func writeDescriptorValue(_ descriptorUUID: CBUUID,
                              characteristicUUID: CBUUID,
                              serviceUUID: CBUUID,
                              value: Data,
                              completion: @escaping WriteRequestCompletion) {
        discoverDescriptorsForCharacteristic(characteristicUUID, serviceUUID: serviceUUID) { [weak self] result in
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            
            
            guard case .success(let descriptors) = result, let descriptor = descriptors.filter({ $0.uuid == descriptorUUID }).first else {
                completion(.failure(BKError.peripheralDescriptorsNotFound(missingDescriptorsUUIDs: [descriptorUUID])))
                return
            }
            
            let request = WriteDescriptorValueRequest(descriptor: descriptor, value: value) { result in
                completion(result)
            }
            
            let writePath = descriptor.uuidPath
            
            if var currentPathRequests = self.writeDescriptorValueRequests[writePath] {
                currentPathRequests.append(request)
                self.writeDescriptorValueRequests[writePath] = currentPathRequests
            } else {
                self.writeDescriptorValueRequests[writePath] = [request]
                
                self.runWriteDescriptorValueRequest(writePath)
            }
        }
    }
    
    private func runWriteDescriptorValueRequest(_ writePath: CBUUIDPath) {
        guard let request = self.writeDescriptorValueRequests[writePath]?.first else {
            return
        }
        
        self.cbPeripheral.writeValue(request.value, for: request.descriptor)
        
        Timer.scheduledTimer(
            timeInterval: BKPeripheralProxy.defaultTimeout,
            target: self,
            selector: #selector(self.writeDescriptorValueRequestTimeout),
            userInfo: request,
            repeats: false)
    }
    
    @objc fileprivate func writeDescriptorValueRequestTimeout(_ timer: Timer) {
        defer { if timer.isValid { timer.invalidate() } }
        
        guard let request = timer.userInfo as? WriteDescriptorValueRequest else { return }
        
        let writePath = request.descriptor.uuidPath
        
        writeDescriptorValueRequests[writePath]?.removeFirst()
        if writeDescriptorValueRequests[writePath]?.isEmpty ?? false {
            writeDescriptorValueRequests[writePath] = nil
        }
        
        request.Completion(.failure(BKError.operationTimedOut(operation: .writeDescriptor)))
        
        runWriteDescriptorValueRequest(writePath)
    }
}

// MARK: Update Characteristic Notification State requests

private final class UpdateNotificationStateRequest {
    let service: CBService
    let characteristic: CBCharacteristic
    let enabled: Bool
    
    let Completion: UpdateNotificationStateCompletion
    
    init(enabled: Bool, characteristic: CBCharacteristic, Completion: @escaping UpdateNotificationStateCompletion) {
        self.enabled = enabled
        self.characteristic = characteristic
        self.service = characteristic.service
        self.Completion = Completion
    }
}

extension BKPeripheralProxy {
    func setNotifyValueForCharacteristic(_ enabled: Bool, characteristicUUID: CBUUID, serviceUUID: CBUUID, completion: @escaping UpdateNotificationStateCompletion) {
        
        discoverCharacteristics([characteristicUUID], forService: serviceUUID) { [weak self] result in
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                completion(.failure(error))
                return
            }
            
            
            guard case .success(let characteristics) = result, let characteristic = characteristics.first else { return }
            
            let request = UpdateNotificationStateRequest(enabled: enabled,
                                                         characteristic: characteristic) { result in
                completion(result)
            }
            
            let path = characteristic.uuidPath
            
            if var currentPathRequests = self.updateNotificationStateRequests[path] {
                currentPathRequests.append(request)
                self.updateNotificationStateRequests[path] = currentPathRequests
            } else {
                self.updateNotificationStateRequests[path] = [request]
                
                self.runUpdateNotificationStateRequest(path)
            }
        }
    }
    
    private func runUpdateNotificationStateRequest(_ path: CBUUIDPath) {
        guard let request = updateNotificationStateRequests[path]?.first else { return }
        
        cbPeripheral.setNotifyValue(request.enabled, for: request.characteristic)
        
        Timer.scheduledTimer(
            timeInterval: BKPeripheralProxy.defaultTimeout,
            target: self,
            selector: #selector(updateNotificationStateRequestTimeout),
            userInfo: request,
            repeats: false)
    }
    
    @objc private func updateNotificationStateRequestTimeout(_ timer: Timer) {
        defer { if timer.isValid { timer.invalidate() } }
        
        guard let request = timer.userInfo as? UpdateNotificationStateRequest else { return }
        
        let path = request.characteristic.uuidPath
        
        updateNotificationStateRequests[path]?.removeFirst()
        if updateNotificationStateRequests[path]?.count == 0 {
            updateNotificationStateRequests[path] = nil
        }
        
        request.Completion(.failure(BKError.operationTimedOut(operation: .updateNotificationStatus)))
        
        runUpdateNotificationStateRequest(path)
    }
}

// MARK: - CBPeripheralDelegate

extension BKPeripheralProxy: CBPeripheralDelegate {
    
    @objc func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        guard let readRSSIRequest = self.readRSSIRequests.first else { return }
        
        if !readRSSIRequests.isEmpty {
            readRSSIRequests.removeFirst()
        }
        
        let result: Result<Int, Error> = {
            if let error = error {
                return .failure(error)
            } else {
                return .success(RSSI.intValue)
            }
        }()
        
        readRSSIRequest.Completion(result)
        
        runRSSIRequest()
    }
    
    @objc func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        var userInfo: [AnyHashable: Any]?
        if let name = peripheral.name {
            userInfo = ["name": name]
        }
        
        self.postPeripheralEvent(BKPeripheral.PeripheralNameUpdate, userInfo: userInfo)
    }
    
    @objc func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        self.postPeripheralEvent(BKPeripheral.PeripheralModifedServices, userInfo: ["invalidatedServices": invalidatedServices])
    }
    
    @objc func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        guard let includedServicesRequest = self.includedServicesRequests.first else {
            return
        }
        
        defer { runIncludedServicesRequest() }
        
        if !includedServicesRequests.isEmpty {
            includedServicesRequests.removeFirst()
        }
        
        if let error = error {
            includedServicesRequest.Completion(.failure(error))
            return
        }
        
        if let serviceUUIDs = includedServicesRequest.serviceUUIDs {
            let servicesTuple = peripheral.servicesWithUUIDs(serviceUUIDs)
            if !servicesTuple.missingServicesUUIDs.isEmpty {
                includedServicesRequest.Completion(.failure(BKError.peripheralServiceNotFound(missingServicesUUIDs: servicesTuple.missingServicesUUIDs)))
            } else {
                includedServicesRequest.Completion(.success(servicesTuple.foundServices))
            }
        } else {
            includedServicesRequest.Completion(.success(service.includedServices ?? []))
        }
    }
    
    @objc func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let serviceRequest = serviceRequests.first else { return }
        
        defer { runServiceRequest() }
        
        if !serviceRequests.isEmpty {
            serviceRequests.removeFirst()
        }
        
        if let error = error {
            serviceRequest.Completion(.failure(error))
            return
        }
        
        if let serviceUUIDs = serviceRequest.serviceUUIDs {
            let servicesTuple = peripheral.servicesWithUUIDs(serviceUUIDs)
            if !servicesTuple.missingServicesUUIDs.isEmpty {
                serviceRequest.Completion(.failure(BKError.peripheralServiceNotFound(missingServicesUUIDs: servicesTuple.missingServicesUUIDs)))
            } else {
                serviceRequest.Completion(.success(servicesTuple.foundServices))
            }
        } else {
            serviceRequest.Completion(.success(peripheral.services ?? []))
        }
    }
    
    @objc func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristicRequest = self.characteristicRequests.first else { return }
        
        defer { runCharacteristicRequest() }
        
        if !characteristicRequests.isEmpty {
            characteristicRequests.removeFirst()
        }
        
        if let error = error {
            characteristicRequest.Completion(.failure(error))
            return
        }
        
        if let characteristicUUIDs = characteristicRequest.characteristicUUIDs {
            let characteristicsTuple = service.characteristicsWithUUIDs(characteristicUUIDs)
            
            if !characteristicsTuple.missingCharacteristicsUUIDs.isEmpty {
                characteristicRequest.Completion(.failure(BKError.peripheralCharacteristicNotFound(missingCharacteristicsUUIDs: characteristicsTuple.missingCharacteristicsUUIDs)))
            } else {
                characteristicRequest.Completion(.success(characteristicsTuple.foundCharacteristics))
            }
        } else {
            characteristicRequest.Completion(.success(service.characteristics ?? []))
        }
    }
    
    @objc func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        guard let descriptorRequest = self.descriptorRequests.first else { return }
        
        defer { runDescriptorRequest() }
        
        if !descriptorRequests.isEmpty {
            descriptorRequests.removeFirst()
        }
        
        if let error = error {
            descriptorRequest.Completion(.failure(error))
        } else {
            descriptorRequest.Completion(.success(characteristic.descriptors ?? []))
        }
    }
    
    @objc func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let readPath = characteristic.uuidPath
        
        guard let request = self.readCharacteristicRequests[readPath]?.first else {
            if characteristic.isNotifying {
                var userInfo: [AnyHashable: Any] = ["characteristic": characteristic]
                if let error = error {
                    userInfo["error"] = error
                }
                
                postPeripheralEvent(BKPeripheral.PeripheralCharacteristicValueUpdate, userInfo: userInfo)
            }
            return
        }
        
        defer { runReadCharacteristicRequest(readPath) }
        
        readCharacteristicRequests[readPath]?.removeFirst()
        if  readCharacteristicRequests[readPath]?.isEmpty ?? false {
            readCharacteristicRequests[readPath] = nil
        }
        
        if let error = error {
            request.Completion(.failure(error))
        } else {
            request.Completion(.success(characteristic.value!))
        }
    }
    
    @objc func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        let writePath = characteristic.uuidPath
        
        guard let request = writeCharacteristicValueRequests[writePath]?.first else { return }
        
        defer { self.runWriteCharacteristicValueRequest(writePath) }
        
        writeCharacteristicValueRequests[writePath]?.removeFirst()
        if writeCharacteristicValueRequests[writePath]?.count == 0 {
            writeCharacteristicValueRequests[writePath] = nil
        }
        
        if let error = error {
            request.Completion(.failure(error))
        } else {
            request.Completion(.success(()))
        }
    }
    
    @objc func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        let path = characteristic.uuidPath
        
        guard let request = self.updateNotificationStateRequests[path]?.first else { return }
        
        defer { self.runUpdateNotificationStateRequest(path) }
        
        updateNotificationStateRequests[path]?.removeFirst()
        if updateNotificationStateRequests[path]?.isEmpty ?? false {
            updateNotificationStateRequests[path] = nil
        }
        
        if let error = error {
            request.Completion(.failure(error))
        } else {
            request.Completion(.success(characteristic.isNotifying))
        }
    }
    
    @objc func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        let readPath = descriptor.uuidPath
        
        guard let request = readDescriptorRequests[readPath]?.first else { return }
        
        defer { runReadCharacteristicRequest(readPath) }
        
        readDescriptorRequests[readPath]?.removeFirst()
        if readDescriptorRequests[readPath]?.isEmpty ?? false {
            readDescriptorRequests[readPath] = nil
        }
        
        if let error = error {
            request.Completion(.failure(error))
        } else {
            do {
                let value = try DescriptorValue(descriptor: descriptor)
                request.Completion(.success(value))
            } catch let error {
                request.Completion(.failure(error))
            }
        }
    }
    
    @objc func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        let writePath = descriptor.uuidPath
        
        guard let request = self.writeDescriptorValueRequests[writePath]?.first else { return }
        
        defer { self.runWriteDescriptorValueRequest(writePath) }
        
        writeDescriptorValueRequests[writePath]?.removeFirst()
        if writeDescriptorValueRequests[writePath]?.isEmpty ?? false {
            writeDescriptorValueRequests[writePath] = nil
        }
        
        if let error = error {
            request.Completion(.failure(error))
        } else {
            request.Completion(.success(()))
        }
    }
}
