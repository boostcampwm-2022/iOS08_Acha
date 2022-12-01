//
//  RxSwift+Extension.swift
//  Acha
//
//  Created by hong on 2022/11/24.
//

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }
    
    var viewWillAppear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { _ in }
        return ControlEvent(events: source)
    }
    var viewDidAppear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidAppear)).map { _ in }
        return ControlEvent(events: source)
    }
    
    var viewWillDisappear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewWillDisappear)).map { _ in }
        return ControlEvent(events: source)
    }
    var viewDidDisappear: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.viewDidDisappear)).map { _ in }
        return ControlEvent(events: source)
    }
}
