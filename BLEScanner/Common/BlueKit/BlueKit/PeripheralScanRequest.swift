//
//  PeripheralScanRequest.swift
//  BlueKit
//
//  Created by Sameh Mabrouk on 06/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

final class PeripheralScanRequest {
    let completion: PeripheralScanCompletion
    var peripherals = [BKPeripheral]()
    
    init(completion: @escaping PeripheralScanCompletion) {
        self.completion = completion
    }
}
