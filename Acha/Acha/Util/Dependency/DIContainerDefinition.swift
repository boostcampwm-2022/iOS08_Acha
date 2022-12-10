//
//  DIContainerDefinition.swift
//  Acha
//
//  Created by hong on 2022/12/10.
//

import Foundation

final class DIContainerDefinition {
    
    private let container = DIContainer.Container.default
    
    func inject() {
        serviceInject()
        repositoryInject()
        useCaseInject()
    }
    
    private func serviceInject() {
        let services: [(protocolType: Any.Type, implement: Any)] = [
            (
                protocolType: TempDBNetwork.self,
                implement: DefaultTempDBNetwork()
            ),
            (
                protocolType: KeychainService.self,
                implement: DefaultKeychainService()
            ),
            (
                protocolType: RealtimeDatabaseNetworkService.self,
                implement: DefaultRealtimeDatabaseNetworkService()
            ),
            (
                protocolType: LocationService.self,
                implement: DefaultLocationService()
            ),
            (
                protocolType: HealthKitService.self,
                implement: DefaultHealthKitService()
            ),
            (
                protocolType: AuthService.self,
                implement: DefaultAuthService()
            ),
            (
                protocolType: RandomService.self,
                implement: DefaultRandomService()
            ),
            (
                protocolType: TimerService.self,
                implement: TimerService()
            )
        ]
        
        services.forEach { service in
            container.register(
                type: service.protocolType,
                implement: service.implement
            )
        }
    }
    
    private func repositoryInject() {
        @DIContainer.Resolve(TempDBNetwork.self)
        var tempDBNetwork: TempDBNetwork
        
        @DIContainer.Resolve(RealtimeDatabaseNetworkService.self)
        var realtimeDatabaseNetworkService: RealtimeDatabaseNetworkService
        
        @DIContainer.Resolve(TimerService.self)
        var timerService: TimerService
        
        @DIContainer.Resolve(LocationService.self)
        var locationService: LocationService
   
        @DIContainer.Resolve(HealthKitService.self)
        var healthKitService: HealthKitService
        
        @DIContainer.Resolve(KeychainService.self)
        var keychainService: KeychainService
        
        @DIContainer.Resolve(AuthService.self)
        var authService: AuthService
        
        @DIContainer.Resolve(RandomService.self)
        var randomService: RandomService
        
        let repositories: [(protocolType: Any.Type, implement: Any)] = [
            (
                protocolType: MapRepository.self,
                implement: DefaultMapRepository(
                    realTimeDatabaseNetworkService: realtimeDatabaseNetworkService
                )
            ),
            (
                protocolType: RecordRepository.self,
                implement: DefaultRecordRepository(
                    realTimeDatabaseNetworkService: realtimeDatabaseNetworkService,
                    healthKitService: healthKitService
                )
            ),
            (
                protocolType: BadgeRepository.self,
                implement: DefaultBadgeRepository(
                    realTimeDatabaseNetworkService: realtimeDatabaseNetworkService
                )
            ),
            (
                protocolType: TempRepository.self,
                implement: DefaultTempRepository(
                    tempDBNetwork: tempDBNetwork
                )
            ),
            (
                protocolType: UserRepository.self,
                implement: DefaultUserRepository(
                    realtimeDataBaseService: realtimeDatabaseNetworkService,
                    keychainService: keychainService,
                    authService: authService
                )
            ),
            (
                protocolType: GameRoomRepository.self,
                implement: DefaultGameRoomRepository(
                    fireBaesRealTimeDatabase: realtimeDatabaseNetworkService,
                    keychainService: keychainService,
                    randomService: randomService
                )
            ),
            (
                protocolType: TimeRepository.self,
                implement: DefaultTimeRepository(
                    timeService: timerService
                )
            ),
            (
                protocolType: LocationRepository.self,
                implement: DefaultLocationRepository(
                    locationService: locationService
                )
            )
        ]
        
        repositories.forEach { repository in
            container.register(type: repository.protocolType, implement: repository.implement)
        }
    }
    
    private func useCaseInject() {
        @DIContainer.Resolve(MapRepository.self)
        var mapRepository: MapRepository
        
        @DIContainer.Resolve(RecordRepository.self)
        var recordRepository: RecordRepository
        
        @DIContainer.Resolve(BadgeRepository.self)
        var badgeRepository: BadgeRepository
        
        @DIContainer.Resolve(TempRepository.self)
        var tempRepository: TempRepository
        
        @DIContainer.Resolve(UserRepository.self)
        var userRepository: UserRepository
        
        @DIContainer.Resolve(GameRoomRepository.self)
        var gameRoomRepository: GameRoomRepository
        
        @DIContainer.Resolve(TimeRepository.self)
        var timeRepository: TimeRepository
        
        @DIContainer.Resolve(LocationRepository.self)
        var locationRepository: LocationRepository
        
        @DIContainer.Resolve(LocationService.self)
        var locationService: LocationService
        
        let useCases: [(protocolType: Any.Type, implement: Any)] = [
            (
                protocolType: RecordMainViewUseCase.self,
                implement: DefaultRecordMainViewUseCase(
                    repository: tempRepository
                )
            ),
            (
                protocolType: RecordMapViewUseCase.self,
                implement: DefaultRecordMainViewUseCase(
                    repository: tempRepository
                )
            ),
            (
                protocolType: SelectMapUseCase.self,
                implement: DefaultSelectMapUseCase(
                    locationService: locationService,
                    mapRepository: mapRepository,
                    recordRepository: recordRepository
                )
            ),
            (
                protocolType: MapBaseUseCase.self,
                implement: DefaultMapBaseUseCase(
                    locationService: locationService
                )
            ),
            (
                protocolType: MyPageUseCase.self,
                implement: DefaultMyPageUseCase(
                    userRepository: userRepository,
                    badgeRepository: badgeRepository
                )
            ),
            (
                protocolType: MultiGameRoomUseCase.self,
                implement: DefaultMultiGameRoomUseCase(
                    repository: gameRoomRepository
                )
            ),
            (
                protocolType: HomeUseCase.self,
                implement: DefaultHomeUseCase(
                    gameRoomRepository: gameRoomRepository,
                    userRepository: userRepository
                )
            ),
            (
                protocolType: MultiGameUseCase.self,
                implement: DefaultMultiGameUseCase(
                    gameRoomRepository: gameRoomRepository,
                    userRepository: userRepository,
                    recordRepository: recordRepository,
                    timeRepository: timeRepository,
                    locationRepository: locationRepository
                )
            )
        ]
        
        useCases.forEach { useCase in
            container.register(type: useCase.protocolType, implement: useCase.implement)
        }
    }
}
