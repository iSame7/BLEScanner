//
//  PeriperalsViewModelTests.swift
//  PeripheralsTests
//
//  Created by Sameh Mabrouk on 12/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import Core
import CoreLocation
import RxCocoa

@testable import Peripherals

class PeripheralsViewModelTests: XCTestCase {
    
    // MARK: - Test variables

    private var sut: PeripheralsViewModel!
    private let peripheralsUseCaseMock = PeripheralsUseCaseMock()
    private var peripheralsMock: Peripheral!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    
    // MARK: - Test life cycle

    override func setUp() {
        super.setUp()
        
        let bkPeripheralMock = BKPeripheralMock()
        bkPeripheralMock.stubbedIdentifier = UUID(uuidString: "33041937-05b2-464a-98ad-3910cbe0d09e")
        peripheralsMock = Peripheral(bkPeripheral: bkPeripheralMock)
        sut = PeripheralsViewModel(useCase: peripheralsUseCaseMock)
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

    func test_viewStateLoaded_updatePeripherals() {
        // given
        let void: Void = ()

        let updatePeripherals = scheduler.createObserver(Void.self)
        sut.outputs.updatePeripherals.bind(to: updatePeripherals).disposed(by: disposeBag)
        peripheralsUseCaseMock.stubbedGetPeripheralsResult =  Observable.just(([peripheralsMock], nil))
        
        // when
        scheduler.createColdObservable([.next(10, ViewState.loaded)])
            .bind(to: sut.inputs.viewState)
            .disposed(by: disposeBag)
        scheduler.start()
        
        // then
        let result: Void? = updatePeripherals.events.first?.value.element!
        XCTAssertTrue(result! == void)
    }
    
    func test_sortPeripherals_updatePeripherals() {
        // given
        let void: Void = ()

        let updatePeripherals = scheduler.createObserver(Void.self)
        sut.outputs.updatePeripherals.bind(to: updatePeripherals).disposed(by: disposeBag)
        peripheralsUseCaseMock.stubbedGetPeripheralsSortedResult =  Observable.just(([peripheralsMock]))
        
        // when
        scheduler.createColdObservable([.next(10, void)])
            .bind(to: sut.inputs.sortPeripherals)
            .disposed(by: disposeBag)
        scheduler.start()
        
        // then
        let result: Void? = updatePeripherals.events.first?.value.element!
        XCTAssertTrue(result! == void)
    }
    
    func test_itemTapped_showPeripheralDetails() {
        // given
        let showPeripheralDetails = scheduler.createObserver(Peripheral.self)
        sut.outputs.showPeripheralDetails.bind(to: showPeripheralDetails).disposed(by: disposeBag)

        // when
        let bkPeripheralMock = BKPeripheralMock()
        bkPeripheralMock.stubbedIdentifier = UUID(uuidString: "33041937-05b2-464a-98ad-3910cbe0d09e")
        
        let peripheral = Peripheral(bkPeripheral: bkPeripheralMock)
        scheduler.createColdObservable([.next(10, peripheral)])
            .bind(to: sut.inputs.itemTapped)
            .disposed(by: disposeBag)
        scheduler.start()
        
        // then
        let result: Peripheral? = showPeripheralDetails.events.first?.value.element!
        XCTAssertEqual(result, peripheral)
    }
}

