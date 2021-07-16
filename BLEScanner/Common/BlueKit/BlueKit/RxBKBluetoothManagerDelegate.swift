//
//  RxBKBluetoothManagerDelegate.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 15/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import RxSwift
import RxCocoa

class RxBKBluetoothManagerDelegateProxy: DelegateProxy<BKBluetoothManager, BKBluetoothManagerDelegate>, DelegateProxyType, BKBluetoothManagerDelegate {
    
    public weak private(set) var bkBluetoothManager: BKBluetoothManager?

    public init(bkBluetoothManager: BKBluetoothManager) {
        self.bkBluetoothManager = bkBluetoothManager
        super.init(parentObject: bkBluetoothManager, delegateProxy: RxBKBluetoothManagerDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { RxBKBluetoothManagerDelegateProxy(bkBluetoothManager: $0) }
    }
    
    static func currentDelegate(for object: BKBluetoothManager) -> BKBluetoothManagerDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: BKBluetoothManagerDelegate?, to object: BKBluetoothManager) {
        object.delegate = delegate
    }
}
