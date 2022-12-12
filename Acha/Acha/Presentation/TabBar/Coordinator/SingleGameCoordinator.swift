//
//  SingleGameCoordinator.swift
//  Acha
//
//  Created by 조승기 on 2022/11/16.
//

import UIKit

protocol SingleGameCoordinatorProtocol: Coordinator {
    func showSelectMapViewController()
    func showSingleGamePlayViewController(selectedMap: Map)
}

final class SingleGameCoordinator: SingleGameCoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    weak var delegate: CoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        childCoordinators = []
    }
    
    func start() {
        showSelectMapViewController()
    }
    
    func showSelectMapViewController() {
        @DIContainer.Resolve(SelectMapUseCase.self)
        var useCase: SelectMapUseCase
        let viewModel = SelectMapViewModel(coordinator: self, selectMapUseCase: useCase)
        let viewController = SelectMapViewController(viewModel: viewModel)
        navigationController.navigationBar.isHidden = true
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showSingleGamePlayViewController(selectedMap: Map) {
        let viewModel = SingleGameViewModel(
            map: selectedMap,
            coordinator: self,
            singleGameUseCase: DefaultSingleGameUseCase(
                map: selectedMap,
                locationService: DefaultLocationService(),
                recordRepository: DefaultRecordRepository(
                    realTimeDatabaseNetworkService: DefaultRealtimeDatabaseNetworkService(),
                    healthKitService: DefaultHealthKitService()
                ),
                tapTimer: TimerService(),
                runningTimer: TimerService(),
                userRepository: DefaultUserRepository(
                    realtimeDataBaseService: DefaultRealtimeDatabaseNetworkService(),
                    keychainService: DefaultKeychainService(),
                    authService: DefaultAuthService()
                )
            )
        )
        let viewController = SingleGameViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showInGameRecordViewController(mapID: Int) {
        let viewModel = InGameRecordViewModel(
            inGameUseCase: DefaultInGameUseCase(
                mapID: mapID,
                recordRepository: DefaultRecordRepository(
                    realTimeDatabaseNetworkService: DefaultRealtimeDatabaseNetworkService(),
                    healthKitService: DefaultHealthKitService()
                ),
                userRepository: DefaultUserRepository(
                    realtimeDataBaseService: DefaultRealtimeDatabaseNetworkService(),
                    keychainService: DefaultKeychainService(),
                    authService: DefaultAuthService()
                )
            )
        )
        let viewController = InGameRecordViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .pageSheet
        self.navigationController.viewControllers.last?.present(viewController, animated: true)
    }
    
    func showInGameRankViewController(mapID: Int) {
        let viewModel = InGameRankingViewModel(
            inGameUseCase: DefaultInGameUseCase(
                mapID: mapID,
                recordRepository: DefaultRecordRepository(
                    realTimeDatabaseNetworkService: DefaultRealtimeDatabaseNetworkService(),
                    healthKitService: DefaultHealthKitService()
                ),
                userRepository: DefaultUserRepository(
                    realtimeDataBaseService: DefaultRealtimeDatabaseNetworkService(),
                    keychainService: DefaultKeychainService(),
                    authService: DefaultAuthService()
                )
            )
        )
        let viewController = InGameRankingViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .pageSheet
        self.navigationController.viewControllers.last?.present(viewController, animated: true)
    }
}
