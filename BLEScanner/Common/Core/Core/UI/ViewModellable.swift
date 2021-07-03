//
//  ViewModellable.swift
//  Core
//
//  Created by Sameh Mabrouk on 03/07/2021.
//  Copyright © 2021 Sameh Mabrouk. All rights reserved.
//

import RxSwift

public protocol ViewModellable {
    var disposeBag: DisposeBag { get }
}
