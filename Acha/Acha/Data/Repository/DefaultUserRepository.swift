//
//  UserRepository.swift
//  Acha
//
//  Created by hong on 2022/12/01.
//

import Foundation
import RxSwift

struct DefaultUserRepository: UserRepository {
    
    private let service: RealtimeDatabaseNetworkService
    private let keychainService: KeyChainManager
    init(
        service: RealtimeDatabaseNetworkService,
        keychainService: KeyChainManager
    ) {
        self.service = service
        self.keychainService = keychainService
    }
    
    func getRoomUser(id: String) -> Single<RoomUser> {
        return service.fetch(type: .user(id: id))
            .map { (userDTO: UserDTO) in
                return userDTO.toRoomUser()
            }
    }
    
}
