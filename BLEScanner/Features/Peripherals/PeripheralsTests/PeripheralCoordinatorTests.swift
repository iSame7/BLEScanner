//
//  PeripheralCoordinatorTests.swift
//  PeripheralsTests
//
//  Created by Sameh Mabrouk on 12/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import XCTest
import Core
import PeripheralDetails
import RxCocoa
import RxTest
import RxSwift

@testable import Peripherals

class PeripheralCoordinatorTests: XCTestCase {
    
    // MARK: - Test variables

    private var sut: PeripheralsCoordinator!
    private var mockWindow: UIWindow!
    private var mockViewController: UINavigationController!
    private var mockPeripheralDetailsModuleBuilder: PeripheralDetailsModuleBuildable!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    
    // MARK: - Test life cycle

    override func setUp() {
        super.setUp()
        
        mockWindow = UIWindow()
        mockViewController = UINavigationController()
        mockPeripheralDetailsModuleBuilder = PeripheralDetailsModuleBuilder()
        sut = PeripheralsCoordinator(window: mockWindow, viewController: mockViewController, peripheralDetailsModuleBuilder: mockPeripheralDetailsModuleBuilder)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        sut = nil
        disposeBag = nil
        scheduler = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func test_start_showAddLocation() {
        // given
        _ = sut.start()
        
        // when
        scheduler.createColdObservable([.next(10, Peripheral(bkPeripheral: BKPeripheralMock()))])
            .bind(to: sut.showPeripheralDetials)
            .disposed(by: disposeBag)
        scheduler.start()
        
        // then
        XCTAssertEqual(sut.childCoordinators.count, 1)
    }
}
