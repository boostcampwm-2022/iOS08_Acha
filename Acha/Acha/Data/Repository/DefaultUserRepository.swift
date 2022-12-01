//
//  DefaultUserRepository.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/01.
//

import RxSwift

final class DefaultUserRepository: UserRepository {
    
    private let realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService
    
    init(realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService) {
        self.realTimeDatabaseNetworkService = realTimeDatabaseNetworkService
    }
    
    func fetchUserData() -> Single<User> {
        guard let userID = try? KeyChainManager.get() else {
            return Single.create { _ in return Disposables.create() }
        }
        return realTimeDatabaseNetworkService.fetch(type: .user(id: userID))
            .map { (userDTO: UserDTO) in
                return userDTO.toDomain()
            }
    }
}
