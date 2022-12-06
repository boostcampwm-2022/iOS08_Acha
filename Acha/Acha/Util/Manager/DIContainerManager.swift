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
    
    static func makeRecordRepository() -> RecordRepository {
        return DefaultRecordRepository(
            realTimeDatabaseNetworkService: DefaultRealtimeDatabaseNetworkService(),
            healthKitService: DefaultHealthKitService()
        )
    }
    
    static func makeLocationRepository() -> LocationRepository {
        return DefaultLocationRepository(locationService: DefaultLocationService())
    }
    
    static func makeTimeRepository() -> TimeRepository {
        return DefaultTimeRepository(timeService: TimerService())
    }
    
    static func makeDefaultHomeUseCase() -> DefaultHomeUseCase {
        return DefaultHomeUseCase(
            gameRoomRepository: makeDefaultGameRoomRepository(),
            userRepository: makeDefaultUserRepository()
        )
    }
    
    static func makeMultiGameUseCase() -> MultiGameUseCase {
        return DefaultMultiGameUseCase(
            gameRoomRepository: makeDefaultGameRoomRepository(),
            userRepository: makeDefaultUserRepository(),
            recordRepository: makeRecordRepository(),
            timeRepository: makeTimeRepository(),
            locationRepository: makeLocationRepository()
        )
    }
}
