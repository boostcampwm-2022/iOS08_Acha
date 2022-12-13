//
//  DependenciesDefinition.swift
//  Acha
//
//  Created by hong on 2022/12/10.
//

import Foundation

final class DependenciesDefinition {
    
    // 인스턴스를 저장할 장소
    private let dependencies = DependenciesContainer.shared
    
    func inject() {
        
        serviceInject()
        repositoryInject()
        useCaseInject()
 
    }
    
    // MARK: - Service
    private func serviceInject() {

        dependencies.register(
            RealtimeDatabaseNetworkService.self,
            implement: DefaultRealtimeDatabaseNetworkService()
        )
        
        dependencies.register(
            LocationService.self,
            implement: DefaultLocationService()
        )
        
        dependencies.register(
            HealthKitService.self,
            implement: DefaultHealthKitService()
        )
        
        dependencies.register(
            KeychainService.self,
            implement: DefaultKeychainService()
        )
        
        dependencies.register(
            TimerService.self,
            implement: TimerService()
        )
        
        dependencies.register(
            AuthService.self,
            implement: DefaultAuthService()
        )
        
        dependencies.register(
            RandomService.self,
            implement: DefaultRandomService()
        )
        
        dependencies.register(
            TempDBNetwork.self,
            implement: DefaultTempDBNetwork()
        )
        
        dependencies.register(
            ImageCacheService.self,
            implement: DefaultImageCacheService()
        )
        
        dependencies.register(
            FirebaseStorageNetworkService.self,
            implement: DefaultFirebaseStorageNetworkService()
        )
    }
    
    //MARK:- Repository
    private func repositoryInject() {

        dependencies.register(
            MapRepository.self,
            implement: DefaultMapRepository(
                realTimeDatabaseNetworkService: dependencies.resolve(RealtimeDatabaseNetworkService.self)
            )
        )
        
        dependencies.register(
            RecordRepository.self,
            implement: DefaultRecordRepository(
                realTimeDatabaseNetworkService: dependencies.resolve(RealtimeDatabaseNetworkService.self),
                healthKitService: dependencies.resolve(HealthKitService.self)
            )
        )
        
        dependencies.register(
            BadgeRepository.self,
            implement: DefaultBadgeRepository(
                realTimeDatabaseNetworkService: dependencies.resolve(RealtimeDatabaseNetworkService.self),
                firebaseStorageNetworkService: dependencies.resolve(FirebaseStorageNetworkService.self),
                imageCacheService: dependencies.resolve(ImageCacheService.self)
            )
        )
        
        dependencies.register(
            TempRepository.self,
            implement: DefaultTempRepository(
                tempDBNetwork: dependencies.resolve(TempDBNetwork.self)
            )
        )
        
        dependencies.register(
            UserRepository.self,
            implement: DefaultUserRepository(
                realtimeDataBaseService: dependencies.resolve(RealtimeDatabaseNetworkService.self),
                keychainService: dependencies.resolve(KeychainService.self),
                authService: dependencies.resolve(AuthService.self)
            )
        )
        
        dependencies.register(
            GameRoomRepository.self,
            implement: DefaultGameRoomRepository(
                fireBaesRealTimeDatabase: dependencies.resolve(RealtimeDatabaseNetworkService.self),
                keychainService: dependencies.resolve(KeychainService.self),
                randomService: dependencies.resolve(RandomService.self)
            )
        )
        
        dependencies.register(
            TimeRepository.self,
            implement: DefaultTimeRepository(
                timeService: dependencies.resolve(TimerService.self)
            )
        )

        dependencies.register(
            LocationRepository.self,
            implement: DefaultLocationRepository(
                locationService: dependencies.resolve(LocationService.self)
            )
        )
    }
    
    //MARK: - UseCase
    private func useCaseInject() {
        
        dependencies.register(
            SelectMapUseCase.self,
            implement: DefaultSelectMapUseCase(
                locationService: dependencies.resolve(LocationService.self),
                mapRepository: dependencies.resolve(MapRepository.self),
                recordRepository: dependencies.resolve(RecordRepository.self)
            )
        )
        
        dependencies.register(
            MapBaseUseCase.self,
            implement: DefaultMapBaseUseCase(
                locationService: dependencies.resolve(LocationService.self)
            )
        )
    
        dependencies.register(
            MyPageUseCase.self,
            implement: DefaultMyPageUseCase(
                userRepository: dependencies.resolve(UserRepository.self),
                badgeRepository: dependencies.resolve(BadgeRepository.self)
            )
        )
        
        // SingleGame, InGame 은 맵이 먼지 몰라서 못 함
        
        dependencies.register(
            MultiGameRoomUseCase.self,
            implement: DefaultMultiGameRoomUseCase(
                repository: dependencies.resolve(GameRoomRepository.self)
            )
        )
        
        dependencies.register(
            HomeUseCase.self,
            implement: DefaultHomeUseCase(
                gameRoomRepository: dependencies.resolve(GameRoomRepository.self),
                userRepository: dependencies.resolve(UserRepository.self)
            )
        )
        
        dependencies.register(
            RecordMainViewUseCase.self,
            implement: DefaultRecordMainViewUseCase(
                repository: dependencies.resolve(TempRepository.self)
            )
        )
        
        dependencies.register(
            RecordMapViewUseCase.self,
            implement: DefaultRecordMainViewUseCase(
                repository: dependencies.resolve(TempRepository.self)
            )
        )
        
        dependencies.register(
            MultiGameUseCase.self,
            implement: DefaultMultiGameUseCase(
                gameRoomRepository: dependencies.resolve(GameRoomRepository.self),
                userRepository: dependencies.resolve(UserRepository.self),
                recordRepository: dependencies.resolve(RecordRepository.self),
                timeRepository: dependencies.resolve(TimeRepository.self),
                locationRepository: dependencies.resolve(LocationRepository.self)
            )
        )
    }
}
