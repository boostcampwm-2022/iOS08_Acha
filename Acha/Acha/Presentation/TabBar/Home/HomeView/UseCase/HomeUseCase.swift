//
//  HomeUseCase.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation
import RxSwift

struct HomeUseCase {
    
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
    
}
