//
//  UIApplication+Rx.swift
//  Acha
//
//  Created by hong on 2022/12/09.
//

import RxSwift
import RxCocoa
import UIKit

public enum Appstate: Equatable {
    case active
    case inactive
    case background
    case terminated
}

extension Reactive where Base: UIApplication {
    var applicationWillEnterForeground: Observable<Appstate> {
        return NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
            .map { _ in
                return .active
            }
    }
    
    var applicationDidBecomActive: Observable<Appstate> {
        return NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
            .map { _ in
                return .active
            }
    }
    
    var applicationDidEnterBackground: Observable<Appstate> {
        return NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification)
            .map { _ in
                return .background
            }
    }
    
    var applicationWillResignActive: Observable<Appstate> {
        return NotificationCenter.default.rx.notification(UIApplication.willResignActiveNotification)
            .map { _ in
                return .inactive
            }
    }
    
    var applicationWillTerminate: Observable<Appstate> {
        return NotificationCenter.default.rx.notification(UIApplication.willTerminateNotification)
            .map { _ in
                return .terminated
            }
    }
    
    public var appState: Observable<Appstate> {
        return Observable.of(
            applicationDidBecomActive,
            applicationWillResignActive,
            applicationWillEnterForeground,
            applicationDidEnterBackground,
            applicationWillTerminate
        )
        .merge()
    }
    
}
