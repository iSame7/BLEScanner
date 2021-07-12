//
//  PeripheralsBuilderTests.swift
//  PeripheralsTests
//
//  Created by Sameh Mabrouk on 12/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import XCTest
import Core

@testable import Peripherals

class PeripheralsBuilderTests: XCTestCase {
    
    // MARK: - Test variables

    private var sut: PeripheralsModuleBuilder!
    private var mockWindow: UIWindow!
    
    // MARK: - Test life cycle

    override func setUp() {
        super.setUp()
        
        mockWindow = UIWindow()
        sut = PeripheralsModuleBuilder()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_build() {
        // when
        
        let peripheralsModule: Module<Void> = sut.buildModule(with: mockWindow)!
        
        let peripheralsCoordinator = try! XCTUnwrap(peripheralsModule.coordinator as? PeripheralsCoordinator)
        
        // then
        
        XCTAssertNotNil(peripheralsCoordinator)
    }
}
