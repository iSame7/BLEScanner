//
//  PeripheralDetailsCoordinator.swift
//  PeripheralDetails
//
//  Created Sameh Mabrouk on 07/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import RxSwift
import Core

class PeripheralDetailsCoordinator: BaseCoordinator<Void> {
    
    private weak var rootViewController: NavigationControllable?
    private let viewController: UIViewController
    
    var viewControllerDismissed = PublishSubject<Void>()

    init(rootViewController: NavigationControllable?, viewController: UIViewController) {
        self.rootViewController = rootViewController
        self.viewController = viewController
    }
    
    override public func start() -> Observable<Void> {
        rootViewController?.pushViewController(viewController, animated: true)
        
        return viewControllerDismissed.map { [weak self] in
            let _ = self?.rootViewController?.popViewController(animated: true)
        }
    }
}
