//
//  HomeRepository.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation
import RxSwift

protocol RoomIDProvider {
    func make() -> String
}

extension RoomIDProvider {
    func make() -> String {
        return RandomFactory.make()
    }
}

protocol UUIDProvider {
    func getUUID() -> Observable<String>
}

extension UUIDProvider {
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
}

struct HomeViewProvider: UUIDProvider, RoomIDProvider {}

protocol HomeRepositoryProtocol {
    func getUUID() -> Observable<String>
    func makeRoomID() -> String
}

struct HomeRepository: HomeRepositoryProtocol {
 
    private let provier: UUIDProvider & RoomIDProvider
    init(provider: UUIDProvider & RoomIDProvider) {
        self.provier = provider
    }
    
    func getUUID() -> RxSwift.Observable<String> {
        return provier.getUUID()
    }
    
    func makeRoomID() -> String {
        return provier.make()
    }
}
