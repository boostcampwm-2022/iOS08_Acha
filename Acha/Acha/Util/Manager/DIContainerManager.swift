//
//  DIContainerManager.swift
//  Acha
//
//  Created by hong on 2022/12/05.
//

import Foundation

struct DiContainerManager {
    
    static func makeDefaultGameRoomRepository() -> DefaultGameRoomRepository {
        
        return DefaultGameRoomRepository(
            fireBaesRealTimeDatabase: DefaultRealtimeDatabaseNetworkService(),
            keychainService: DefaultKeychainService(),
            randomService: DefaultRandomService()
        )
    }
    
    static func makeDefaultUserRepository() -> DefaultUserRepository {
        return DefaultUserRepository(
            realtimeDataBaseService: DefaultRealtimeDatabaseNetworkService(),
            keychainService: DefaultKeychainService(),
            authService: DefaultAuthService()
        )
    }
    
    static func makeDefaultHomeUseCase() -> DefaultHomeUseCase {
        return DefaultHomeUseCase(
            gameRoomRepository: makeDefaultGameRoomRepository(),
            userRepository: makeDefaultUserRepository()
        )
    }
}
