//
//  SceneDelegate.swift
//  BLEScanner
//
//  Created by Sameh Mabrouk on 03/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit
import RxSwift
import Core

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var rootBuilder = RootBuilder()
    private let disposeBag = DisposeBag()
    private var appRootCoordinator: BaseCoordinator<Void>?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            self.window = window
            window.makeKeyAndVisible()
            
            appRootCoordinator = rootBuilder.buildModule(with: window)?.coordinator
            guard let appRootCoordinator = appRootCoordinator else {
                preconditionFailure("[SceneDelegate] Cannot get appRootCoordinator from module builder")
            }
            
            appRootCoordinator.start()
                .subscribe()
                .disposed(by: disposeBag)
        }
    }
}

