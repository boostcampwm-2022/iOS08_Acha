//
//  HomeProvider.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation
import RxSwift

protocol HomeProviderProtocol: UUIDGetable {
    func getUUID() -> Observable<String>
    func enterRoom(id: String)
    func makeRoomID() -> String
}

extension HomeProviderProtocol {
    func makeRoomID() -> String {
        return RandomFactory.make()
    }
}

struct HomeProvider: HomeProviderProtocol {
    func enterRoom(id: String) {
        guard let uuid = try? KeyChainManager.get() else {return}
        FBRealTimeDB().enterRoom(
            FBRealTimeDBType.user(id: uuid, data: nil),
            FBRealTimeDBType.room(id: id, data: nil)
        )
    }
}
