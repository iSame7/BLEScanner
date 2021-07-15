//
//  BKBluetoothManager.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 13/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import CoreBluetooth

public protocol BKBluetoothControling {
    func scanForPeripherals()
    func stopScanForPeripherals()
    
    func connectPeripheral(_ peripheral: CBPeripheral)
    func disconnectPeripheral()
    
    func discoverDescriptor(_ characteristic: CBCharacteristic)
    
    func discoverCharacteristics()
    func readValueForCharacteristic(characteristic: CBCharacteristic)
    func writeValue(data: Data, forCharacteristic characteristic: CBCharacteristic, type: CBCharacteristicWriteType)
    
    func setNotification(enable: Bool, forCharacteristic characteristic: CBCharacteristic)
}

public class BKBluetoothManager: NSObject {
    
    public let shared = BKBluetoothManager()
    
    private(set) var centralManager: CBCentralManager!
    private(set) var notificationCenter: NotificationCenter!
    
    var state: CBManagerState? {
        return CBManagerState(rawValue: centralManager.state.rawValue)
    }
    
    private var isConnecting = false
    private(set) var isConnected = false
    private(set) var connectedPeripheral : CBPeripheral?
    private(set) var connectedServices : [CBService]?
    
    private var connectionTimer : Timer?
    private let connectionTimeout = TimeInterval(2.0)
    
    private var interrogatePeripheralTimer : Timer? /// Timeout monitor of interrogate the peripheral
    
    weak var delegate: BKBluetoothManagerDelegate?
    
    init(notificationCenter: NotificationCenter = .default) {
        super.init()

        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])
        self.notificationCenter = notificationCenter
    }
}

// MARK: - BKPeripheralBLECabable

extension BKBluetoothManager: BKBluetoothControling {
    
    public func scanForPeripherals() {
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    public func stopScanForPeripherals() {
        centralManager.stopScan()
    }
    
    public func connectPeripheral(_ peripheral: CBPeripheral) {
        if !isConnecting {
            isConnecting = true
            centralManager.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: true])
            connectionTimer = Timer.scheduledTimer(timeInterval: connectionTimeout, target: self, selector: #selector(connectTimeout(_:)), userInfo: peripheral, repeats: false)
        }
    }
    
    public func disconnectPeripheral() {
        guard let connectedPeripheral = connectedPeripheral else {
            return
        }
        
        centralManager.cancelPeripheralConnection(connectedPeripheral)
        scanForPeripherals()
        self.connectedPeripheral = nil
    }
    
    public func discoverDescriptor(_ characteristic: CBCharacteristic) {
        guard let connectedPeripheral = connectedPeripheral else {
            return
        }
        
        connectedPeripheral.discoverDescriptors(for: characteristic)
    }
    
    public func discoverCharacteristics() {
        guard let connectedPeripheral = connectedPeripheral, let services = connectedPeripheral.services, !services.isEmpty else {
            return
        }
                
        for service in services {
            connectedPeripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    public func readValueForCharacteristic(characteristic: CBCharacteristic) {
        guard let connectedPeripheral = connectedPeripheral else {
            return
        }
        
        connectedPeripheral.readValue(for: characteristic)
    }
    
    public func writeValue(data: Data, forCharacteristic characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        guard let connectedPeripheral = connectedPeripheral else {
            return
        }
        
        connectedPeripheral.writeValue(data, for: characteristic, type: type)
    }
    
    public func setNotification(enable: Bool, forCharacteristic characteristic: CBCharacteristic) {
        guard let connectedPeripheral = connectedPeripheral else {
            return
        }
        
        connectedPeripheral.setNotifyValue(enable, for: characteristic)
    }
    
    
    // Helpers
    
    /**
     The method is invoked when connect peripheral is timeout
     
     - parameter timer: The timer touch off this selector
     */
    @objc func connectTimeout(_ timer : Timer) {
        if isConnecting {
            isConnecting = false
            if let peripheral = timer.userInfo as? CBPeripheral {
                connectPeripheral(peripheral)
            }
            connectionTimer = nil
        }
    }
    
    @objc func integrrogatePeripheralTimeout(_ timer: Timer) {
        disconnectPeripheral()
        if let peripheral = timer.userInfo as? CBPeripheral {
            delegate?.didFailedToInterrogate(peripheral)
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension BKBluetoothManager: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("[BKBluetoothManager] State: Powered Off")
        case .poweredOn:
            print("[BKBluetoothManager] State: Powered On")
        case .resetting:
            print("[BKBluetoothManager] State: Resetting")
        case .unauthorized:
            print("[BKBluetoothManager] State: Unauthorized")
        case .unknown:
            print("[BKBluetoothManager] State: Unknown")
        case .unsupported:
            print("[BKBluetoothManager] State: Unsupported")
        @unknown default:
            print("[BKBluetoothManager] State: Unknown")
        }
        if let state = self.state {
            delegate?.didUpdateState(state)
        }
    }
    
    /**
     This method is invoked while scanning, upon the discovery of peripheral by central
     
     - parameter central:           The central manager providing this update.
     - parameter peripheral:        The discovered peripheral.
     - parameter advertisementData: A dictionary containing any advertisement and scan response data.
     - parameter RSSI:              The current RSSI of peripheral, in dBm. A value of 127 is reserved and indicates the RSSI
     *                                was not available.
     */
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Bluetooth Manager --> didDiscoverPeripheral, RSSI:\(RSSI)")
        delegate?.didDiscoverPeripheral(peripheral, advertisementData: advertisementData, RSSI: RSSI)
    }
    
    /**
     This method is invoked when a connection succeeded
     
     - parameter central:    The central manager providing this information.
     - parameter peripheral: The peripheral that has connected.
     */
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Bluetooth Manager --> didConnectPeripheral")
        isConnecting = false
        if connectionTimer != nil {
            connectionTimer!.invalidate()
            connectionTimer = nil
        }
        isConnected = true
        connectedPeripheral = peripheral
        delegate?.didConnectedPeripheral(peripheral)
        stopScanForPeripherals()
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        interrogatePeripheralTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.integrrogatePeripheralTimeout(_:)), userInfo: peripheral, repeats: false)
    }
    
    /**
     This method is invoked where a connection failed.
     
     - parameter central:    The central manager providing this information.
     - parameter peripheral: The peripheral that you tried to connect.
     - parameter error:      The error infomation about connecting failed.
     */
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Bluetooth Manager --> didFailToConnectPeripheral")
        isConnecting = false
        if connectionTimer != nil {
            connectionTimer!.invalidate()
            connectionTimer = nil
        }
        isConnected = false
        delegate?.didFailToConnectPeripheral(peripheral, error: error!)
    }
}

// MARK: - CBPeripheralDelegate

extension BKBluetoothManager: CBPeripheralDelegate {
    
    /**
     The method is invoked where services were discovered.
     
     - parameter peripheral: The peripheral with service informations.
     - parameter error:      Errot message when discovered services.
     */
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Bluetooth Manager --> didDiscoverServices")
        connectedPeripheral = peripheral
        if error != nil {
            print("Bluetooth Manager --> Discover Services Error, error:\(error?.localizedDescription ?? "")")
            return ;
        }
        
        // If discover services, then invalidate the timeout monitor
        if interrogatePeripheralTimer != nil {
            interrogatePeripheralTimer?.invalidate()
            interrogatePeripheralTimer = nil
        }
        
        self.delegate?.didDiscoverServices(peripheral)
    }
    
    /**
     The method is invoked where characteristics were discovered.
     
     - parameter peripheral: The peripheral provide this information
     - parameter service:    The service included the characteristics.
     - parameter error:      If an error occurred, the cause of the failure.
     */
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Bluetooth Manager --> didDiscoverCharacteristicsForService")
        if error != nil {
            print("Bluetooth Manager --> Fail to discover characteristics! Error: \(error?.localizedDescription ?? "")")
            delegate?.didFailToDiscoverCharacteritics(error!)
            return
        }
        delegate?.didDiscoverCharacteritics(service)
    }
    
    /**
     This method is invoked when the peripheral has found the descriptor for the characteristic
     
     - parameter peripheral:     The peripheral providing this information
     - parameter characteristic: The characteristic which has the descriptor
     - parameter error:          The error message
     */
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("Bluetooth Manager --> didDiscoverDescriptorsForCharacteristic")
        if error != nil {
            print("Bluetooth Manager --> Fail to discover descriptor for characteristic Error:\(error?.localizedDescription ?? "")")
            delegate?.didFailToDiscoverDescriptors(error!)
            return
        }
        delegate?.didDiscoverDescriptors(characteristic)
    }
    
    /**
     This method is invoked when the peripheral has been disconnected.
     
     - parameter central:    The central manager providing this information
     - parameter peripheral: The disconnected peripheral
     - parameter error:      The error message
     */
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Bluetooth Manager --> didDisconnectPeripheral")
        isConnected = false
        self.delegate?.didDisconnectPeripheral(peripheral)
        notificationCenter.post(name: .disconnect, object: self)
    }
    
    /**
     Thie method is invoked when the user call the peripheral.readValueForCharacteristic
     
     - parameter peripheral:     The periphreal which call the method
     - parameter characteristic: The characteristic with the new value
     - parameter error:          The error message
     */
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Bluetooth Manager --> didUpdateValueForCharacteristic")
        if error != nil {
            print("Bluetooth Manager --> Failed to read value for the characteristic. Error:\(error!.localizedDescription)")
            delegate?.didFailToReadValueForCharacteristic(error!)
            return
        }
        delegate?.didReadValueForCharacteristic(characteristic)
        
    }
}
