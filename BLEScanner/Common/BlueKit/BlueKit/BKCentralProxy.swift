//
//  BKCentralManager.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 06/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import CoreBluetooth

final class BKCentralProxy: NSObject {
    
    lazy var stateCompletions: [CentralStateCompletion] = []
    var scanRequest: PeripheralScanRequest?
    lazy var connectRequests: [UUID: PeripheralRequest] = [:]
    lazy var disconnectRequests: [UUID: PeripheralRequest] = [:]
    var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    init(stateRestoreIdentifier: String) {
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: stateRestoreIdentifier])
    }
    
    private func postCentralEvent(_ event: NSNotification.Name, userInfo: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(
            name: event,
            object: BKCentral.shared,
            userInfo: userInfo)
    }
}

// MARK: Initialize Bluetooth requests
extension BKCentralProxy {
    func checkState(_ completion: @escaping CentralStateCompletion) {
        switch centralManager.state {
        case .unknown:
            stateCompletions.append(completion)
        case .resetting:
            stateCompletions.append(completion)
        case .unsupported:
            completion(.unsupported)
        case .unauthorized:
            completion(.unauthorized)
        case .poweredOff:
            completion(.poweredOff)
        case .poweredOn:
            completion(.poweredOn)
        @unknown default:
            completion(.unknown)
        }
    }
    
    func initializeBluetooth(_ completion: @escaping InitializeBluetoothCompletion) {
        self.checkState { (state) in
            switch state {
            case .unsupported:
                completion(.bluetoothUnavailable(reason: .unsupported))
            case .unauthorized:
                completion(.bluetoothUnavailable(reason: .unauthorized))
            case .poweredOff:
                completion(.bluetoothUnavailable(reason: .poweredOff))
            case .poweredOn:
                completion(nil)
            case .unknown:
                completion(.bluetoothUnavailable(reason: .unknown))
            }
        }
    }
    
    func invokeCentralStateCompletion(_ state: BKCentralState) {
        stateCompletions.forEach { completion in
            completion(state)
        }
        
        stateCompletions.removeAll()
    }
}

// MARK: - Helpers

extension BKCentralProxy {
    func scanWithTimeout(_ timeout: TimeInterval, serviceUUIDs: [CBUUID]?, options: [String : Any]?, _ completion: @escaping PeripheralScanCompletion) {
        initializeBluetooth { [unowned self] (error) in
            if let error = error {
                completion(PeripheralScanResult.scanStopped(peripherals: [], error: error))
            } else {
                if self.scanRequest != nil {
                    self.centralManager.stopScan()
                }
                
                let scanRequest = PeripheralScanRequest(completion: completion)
                self.scanRequest = scanRequest
                
                scanRequest.completion(.scanStarted)
                self.centralManager.scanForPeripherals(withServices: serviceUUIDs, options: options)
                
                Timer.scheduledTimer(
                    timeInterval: timeout,
                    target: self,
                    selector: #selector(self.onScanTimerTick),
                    userInfo: scanRequest,
                    repeats: false)
            }
        }
    }
    
    func stopScan(error: BKError? = nil) {
        if centralManager.state != .poweredOff, centralManager.state != .unsupported {
            self.centralManager.stopScan()
        }

        if let scanRequest = self.scanRequest {
            self.scanRequest = nil
            scanRequest.completion(.scanStopped(peripherals: scanRequest.peripherals, error: error))
        }
    }
    
    @objc fileprivate func onScanTimerTick(_ timer: Timer) {
        defer { if timer.isValid { timer.invalidate() } }
        
        guard let _ = timer.userInfo as? PeripheralScanRequest else { return }
        
        stopScan()
    }
}

// MARK: - Connect Peripheral requests

extension BKCentralProxy {
    func connect(peripheral: CBPeripheral, timeout: TimeInterval, _ Completion: @escaping ConnectPeripheralCompletion) {
        initializeBluetooth { [unowned self] (error) in
            if let error = error {
                Completion(.failure(error))
                return
            }
            
            let uuid = peripheral.identifier
            
            if let cbPeripheral = self.centralManager.retrievePeripherals(withIdentifiers: [uuid]).first , cbPeripheral.state == .connected {
                Completion(.success(()))
                return
            }
            
            if let request = self.connectRequests[uuid] {
                request.connectPeripheralcompletions.append(Completion)
            } else {
                let request = PeripheralRequest(peripheral: peripheral, connectPeripheralcompletion: Completion)
                self.connectRequests[uuid] = request
                
                self.centralManager.connect(peripheral, options: nil)
                Timer.scheduledTimer(
                    timeInterval: timeout,
                    target: self,
                    selector: #selector(self.onConnectTimerTick),
                    userInfo: request,
                    repeats: false)
            }
        }
    }
    
    @objc fileprivate func onConnectTimerTick(_ timer: Timer) {
        defer { if timer.isValid { timer.invalidate() } }
        
        guard let request = timer.userInfo as? PeripheralRequest else { return }
        
        let uuid = request.peripheral.identifier
        
        self.connectRequests[uuid] = nil
        
        self.centralManager.cancelPeripheralConnection(request.peripheral)
        
        request.invokeConnectPeripheralCompletions(error: BKError.operationTimedOut(operation: .connectPeripheral))
    }
}

// MARK: - Disconnect Peripheral requests

extension BKCentralProxy {
    
    func disconnect(peripheral: CBPeripheral, timeout: TimeInterval, _ Completion: @escaping DisconnectPeripheralCompletion) {
        initializeBluetooth { [unowned self] (error) in
            
            if let error = error {
                Completion(.failure(error))
                return
            }
            
            let uuid = peripheral.identifier
            
            if let cbPeripheral = self.centralManager.retrievePeripherals(withIdentifiers: [uuid]).first,
                (cbPeripheral.state == .disconnected || cbPeripheral.state == .disconnecting) {
                Completion(.success(()))
                return
            }
            
            if let request = self.disconnectRequests[uuid] {
                request.disconnectPeripheralcompletions.append(Completion)
            } else {
                let request = PeripheralRequest(peripheral: peripheral, disconnectPeripheralcompletion: Completion)
                self.disconnectRequests[uuid] = request
                
                self.centralManager.cancelPeripheralConnection(peripheral)
                Timer.scheduledTimer(
                    timeInterval: timeout,
                    target: self,
                    selector: #selector(self.onDisconnectTimerTick),
                    userInfo: request,
                    repeats: false)
            }
        }
    }
    
    @objc fileprivate func onDisconnectTimerTick(_ timer: Timer) {
        defer { if timer.isValid { timer.invalidate() } }
        
        guard let request = timer.userInfo as? PeripheralRequest else { return }
        
        let uuid = request.peripheral.identifier
        
        disconnectRequests[uuid] = nil
        
        request.invokeDisconnectPeripheralCompletions(error: BKError.operationTimedOut(operation: .disconnectPeripheral))
    }
}

// MARK: - CBCentralManagerDelegate

extension BKCentralProxy: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        postCentralEvent(BKCentral.centralStateChange, userInfo: ["state": central.state])
        
        switch central.state.rawValue {
        case 0: // .unknown
            stopScan(error: .scanningEndedUnexpectedly)
        case 1: // .resetting
            stopScan(error: .scanningEndedUnexpectedly)
        case 2: // .unsupported
            invokeCentralStateCompletion(.unsupported)
            stopScan(error: .scanningEndedUnexpectedly)
        case 3: // .unauthorized
            invokeCentralStateCompletion(.unauthorized)
            stopScan(error: .scanningEndedUnexpectedly)
        case 4: // .poweredOff
            invokeCentralStateCompletion(.poweredOff)
            stopScan(error: .scanningEndedUnexpectedly)
        case 5: // .poweredOn
            invokeCentralStateCompletion(.poweredOn)
        default:
            assertionFailure("[BKCentralProxy]: Unsupported BLE CentralState")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let uuid = peripheral.identifier
        guard let request = connectRequests[uuid] else {
            return
        }
        
        connectRequests[uuid] = nil
        
        request.invokeConnectPeripheralCompletions(error: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let uuid = peripheral.identifier
        
        var userInfo: [AnyHashable: Any] = ["identifier": uuid]
        if let error = error {
            userInfo["error"] = error
        }
        
        postCentralEvent(BKCentral.centralCBPeripheralDisconnected, userInfo: userInfo)
        
        guard let request = disconnectRequests[uuid] else { return }
        
        disconnectRequests[uuid] = nil
        request.invokeDisconnectPeripheralCompletions(error: error)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let uuid = peripheral.identifier
        guard let request = connectRequests[uuid] else {
            return
        }
        
        let resolvedError: Error = error ?? BKError.peripheralFailedToConnectReasonUnknown
        
        connectRequests[uuid] = nil
        
        request.invokeConnectPeripheralCompletions(error: resolvedError)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        guard let scanRequest = scanRequest else { return }
        
        let peripheral = Peripheral(peripheral: peripheral)
        scanRequest.peripherals.append(peripheral)
        
        var rssiOptional: Int? = Int(truncating: RSSI)
        if let rssi = rssiOptional, rssi == 127 {
            rssiOptional = nil
        }
        
        scanRequest.completion(.scanResult(peripheral: peripheral, advertisementData: advertisementData, RSSI: rssiOptional))
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
//        let peripherals = ((dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral]) ?? []).map { Peripheral(peripheral: $0) }
//        postCentralEvent(Central.CentralManagerWillRestoreState, userInfo: ["peripherals": peripherals])
    }
}
