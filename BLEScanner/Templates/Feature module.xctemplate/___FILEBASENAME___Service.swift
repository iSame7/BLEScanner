//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import RxSwift
import Apollo
import Core

public protocol ___VARIABLE_productName:identifier___ServicePerforming {
    func doSomething() -> Single<Bool>
}

class ___VARIABLE_productName:identifier___Service: ___VARIABLE_productName:identifier___ServicePerforming {
    
    private let client: GraphQLClientProtocol
    private let serviceErrorListener: ServiceErrorListener
    
    public init(client: GraphQLClientProtocol, serviceErrorListener: ServiceErrorListener) {
        self.client = client
        self.serviceErrorListener = serviceErrorListener
    }
    
    
    func doSomething() -> Single<Bool> {
        return .just(true)
    }
}

private extension ___VARIABLE_productName:identifier___Service {
    func notifyError(_ error: Error) {
        serviceErrorListener.notifyError(errorMessage: error.localizedDescription, error: error)
    }
}
