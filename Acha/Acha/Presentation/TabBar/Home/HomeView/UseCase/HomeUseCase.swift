//
//  HomeUseCase.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation
import RxSwift

protocol HomeUseCaseProtocol {
    func getUUID() -> Observable<String>
    func makeRoomID() -> String
    func enterRoom(roomID: String)
}

struct HomeUseCase: HomeUseCaseProtocol {
    
    private let repository: HomeRepositoryProtocol
    init(repository: HomeRepositoryProtocol) {
        self.repository = repository
    }
    
    func getUUID() -> Observable<String> {
        return repository.getUUID()
    }
    
    func makeRoomID() -> String {
        return repository.makeRoomID()
    }
    
    func enterRoom(roomID: String) {
        repository.enterRoom(roomID: roomID)
    }
    
}
