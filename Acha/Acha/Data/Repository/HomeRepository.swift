//
//  HomeRepository.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation
import RxSwift

protocol HomeRepositoryProtocol {
    func getUUID() -> Observable<String>
    func makeRoomID() -> String
    func enterRoom(roomID: String)
}

struct HomeRepository: HomeRepositoryProtocol {
 
    private let provider: HomeProviderProtocol
    init(provider: HomeProviderProtocol) {
        self.provider = provider
    }
    
    func getUUID() -> RxSwift.Observable<String> {
        return provider.getUUID()
    }
    
    func makeRoomID() -> String {
        return provider.makeRoomID()
    }
    
    func enterRoom(roomID: String) {
        provider.enterRoom(id: roomID)
    }
}
