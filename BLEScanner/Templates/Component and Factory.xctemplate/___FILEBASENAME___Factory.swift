//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

class ___VARIABLE_MODULENAME___Factory<T>: Factory {
    public typealias ComponentType = T
    
    public lazy var playbookPresentationSize: CGRect = {
        return CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 48, height: 48)
    }()

    public func build() -> T {
        return <component> as! T
    }
}
