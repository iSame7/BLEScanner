//
//  Central.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 06/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import Foundation
import CoreBluetooth

typealias InitializeBluetoothCompletion = (_ error: BKError?) -> Void
public typealias CentralStateCompletion = (BKCentralState) -> Void
public typealias ConnectPeripheralCompletion = (Result<Void, Error>) -> Void
public typealias DisconnectPeripheralCompletion = (Result<Void, Error>) -> Void
public typealias PeripheralScanCompletion = (PeripheralScanResult) -> Void

public enum PeripheralScanResult {
    case scanStarted
    case scanResult(peripheral: BKPeripheral, advertisementData: [String: Any], RSSI: Int?)
    case scanStopped(peripherals: [BKPeripheral], error: BKError?)
}

public enum BKCentralState: Int {
    case unsupported = 2
    case unauthorized = 3
    case poweredOff = 4
    case poweredOn = 5
    case unknown = -1
}

public protocol BKCentralManaging {
    func scanForPeripherals(withServiceUUIDs serviceUUIDs: [CBUUIDConvertible]?,
                                   options: [String : Any]?,
                                   timeoutAfter timeout: TimeInterval?,
                                   completion: @escaping PeripheralScanCompletion)
    func stopScan()
    func checkState(completion: @escaping CentralStateCompletion)
}

public final class BKCentral {
    
    public static let shared = BKCentral()
    
    private let centralProxy: BKCentralProxy

    public static let centralCBPeripheralDisconnected = Notification.Name("BKCentralCBPeripheralDisconnected")
    public static let centralStateChange = Notification.Name("BKCentralStateChange")
    public static let centralManagerWillRestoreState = Notification.Name("BKCentralManagerWillRestoreStateNotification")

    private init(centralProxy: BKCentralProxy = BKCentralProxy()) {
        self.centralProxy = centralProxy
    }
    
    private init(stateRestoreIdentifier: String) {
        self.centralProxy = BKCentralProxy(stateRestoreIdentifier: stateRestoreIdentifier)
    }
}

// MARK: - Internals

extension BKCentral {
    
    func initBluetooth(completion: @escaping InitializeBluetoothCompletion) {
        centralProxy.initializeBluetooth(completion)
    }
    
    func connect(peripheral: CBPeripheral,
                 timeout: TimeInterval = 10,
                 completion: @escaping ConnectPeripheralCompletion) {
        centralProxy.connect(peripheral: peripheral, timeout: timeout, completion)
    }
    
    func disconnect(peripheral: CBPeripheral,
                    timeout: TimeInterval = 10,
                    completion: @escaping DisconnectPeripheralCompletion) {
        centralProxy.disconnect(peripheral: peripheral, timeout: timeout, completion)
    }
}

//MARK: - BKCentralManaging

extension BKCentral: BKCentralManaging {
    
    public func scanForPeripherals(withServiceUUIDs serviceUUIDs: [CBUUIDConvertible]?, options: [String : Any]? = nil, timeoutAfter timeout: TimeInterval?, completion: @escaping PeripheralScanCompletion) {
        centralProxy.scanWithTimeout(timeout, serviceUUIDs: extractCBUUIDs(serviceUUIDs), options: options, completion)
    }
    
    public func stopScan() {
        centralProxy.stopScan()
    }
    
    public func checkState(completion: @escaping CentralStateCompletion) {
        centralProxy.checkState(completion)
    }
}
