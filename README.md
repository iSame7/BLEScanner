# BLEScanner
========================

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)

## Overview

- The architecture that underpins the development of this app can be found [here](https://github.com/iSame7/BLEScanner/blob/master/Technical-Documents/Architecture.md)

<img src="/Assets/peripherals.png" alt="Screenshot" width="320px"/>

<img src="/Assets/peripheralDetails.png" alt="Screenshot" width="320px"/>

<img src="/Assets/BLEDisabled.png" alt="Screenshot" width="320px"/>

## App Description

Using this application, a user should be able to see a list of nearby Bluetooth devices.

**Improvements**
* Increase unit test code coverage
* Add filter functionality to filter out peripherals based on RSSI
* Add loading state for details screen by using shimmer effect
* Ability to edit characteristic of a peripheral

## Installation

Just clone the repo or download it in zip-file, Open the project in Xcode, switch to `BLEScanner` Scheme then test it on your iOS device.

# Xcode Project files structure
```bash
.swift
+-- Common
|   +-- Core
|   +-- BlueKit
+-- Features
|   +-- Peripherals
    |   +-- Builder
            |   +-- PeripheralsModuleBuilder.swift
    |   +-- Coordinator
            |   +-- PeripheralsCoordinator.swift
    |   +-- Service
            |   +-- PeripheralsService.swift
    |   +-- UseCase
            |   +-- PeripheralsUseCase.swift
    |   +-- View
            |   +-- PeripheralsViewController.swift
            |   +-- PeripheralCell.swift            
    |   +-- ViewModel
            |   +-- PeripheralsViewModel.swift
|   +-- PeripheralDetails

+-- ProjectX
+-- Pods
```

# Design Patterns used:

Check the architecture that underpins the development of the apps in this repository [here](https://github.com/iSame7/BLEScanner/blob/master/Technical-Documents/Architecture.md)

# Unit testing:

I started from testing interactor and presenter, because interactor contains main business logic and presenter contains logic responsible for preparing data before displaying. These components seems more critical than others.

Libraries/Frameworks i used for unit tests and TDD:

* XCTest


Every module is strictly separated what creates a very friendly scenario for adopting unit tests in terms of single responsibility principle:

let’s consider an example of a presenter of List Characters Module:

by separating components in our test we can focus only on testing responsibility of interactor. The others components which talk with interactor are just mocked.

How does it look like in perspective of code?

```swift
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
```
