//
//  ViewController.swift
//  Core
//
//  Created by Sameh Mabrouk on 03/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import UIKit

open class ViewController<T: ViewModellable>: UIViewController, ViewControllable {
    
    open var viewModel: T!
    
    public var uiviewController: UIViewController {
        return self
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, unavailable, message: "NSCoder and Interface Builder is not supported. Use Programmatic layout.")
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setupUI() {}
    
    open func setupConstraints() {}
    
    open func setupObservers() {}
}
