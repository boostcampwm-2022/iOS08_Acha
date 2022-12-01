//
//  DefaultUserRepository.swift
//  Acha
//
//  Created by hong on 2022/12/02.
//

import Foundation
import RxSwift

struct DefaultUserRepository {
    
    private let realtimeDataBaseService: RealtimeDatabaseNetworkService
    private let keychainService: KeychainService
    private let disposeBag = DisposeBag()
    
    init(
        realtimeDataBaseService: RealtimeDatabaseNetworkService,
        keychainService: KeychainService
    ) {
        self.realtimeDataBaseService = realtimeDataBaseService
        self.keychainService = keychainService
    }
    
    func getUUID() -> String? {
        return keychainService.get()
    }
    
    func getUserData() -> Single<UserDTO> {
        return Single<UserDTO>.create { single in
            guard let uuid = getUUID() else {
                single(.failure(KeyChainManager.KeychainServiceError.notLogined))
                return Disposables.create()
            }
            getUserDataFromRealTimeDataBaseService(uuid: uuid)
                .subscribe { userDTO in
                    single(.success(userDTO))
                }
                .disposed(by: disposeBag)
            return Disposables.create()
        }
    }
    
    private func getUserDataFromRealTimeDataBaseService(uuid: String) -> Single<UserDTO> {
        return realtimeDataBaseService.fetch(type: .user(id: uuid))
    }
}
