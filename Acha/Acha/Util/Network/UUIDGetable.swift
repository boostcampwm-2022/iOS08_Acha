//
//  UUIDGetable.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation
import RxSwift

protocol UUIDGetable {
    func getUUID() -> Observable<String>
}

extension UUIDGetable {
    func getUUID() -> RxSwift.Observable<String> {
        return Observable<String>.create { observer in
            do {
                let id = try KeyChainManager.get()
                observer.onNext(id)
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func make() -> String {
        return RandomFactory.make()
    }
    
}
