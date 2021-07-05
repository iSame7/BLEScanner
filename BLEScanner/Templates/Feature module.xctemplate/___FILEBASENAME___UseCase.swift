//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import RxSwift

public protocol ___VARIABLE_productName:identifier___Interactable {
    func doSomething() -> Single<Bool>
}

class ___VARIABLE_productName:identifier___UseCase: ___VARIABLE_productName:identifier___Interactable {

    private let service: ___VARIABLE_productName:identifier___ServicePerforming
    
    init(service: ___VARIABLE_productName:identifier___ServicePerforming) {
        self.service = service
    }
    
    func doSomething() -> Single<Bool> {
        service.doSomething()
    }
}
