//
//  Service.swift
//  Core
//
//  Created by Sameh Mabrouk on 08/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

public struct Service {
    public let name: String
    public let characteristics: [Characteristic]
    
    public init(name: String, characteristics: [Characteristic]) {
        self.name = name
        self.characteristics = characteristics
    }
}

public struct Characteristic {
    public let name: String
    public let properties: String
    public let value: String?
    
    public init(name: String, properties: String, value: String?) {
        self.name = name
        self.properties = properties
        self.value = value
    }
}
