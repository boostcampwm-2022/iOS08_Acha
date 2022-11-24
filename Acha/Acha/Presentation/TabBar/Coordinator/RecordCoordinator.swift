//
//  RecordCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

protocol RecordCoordinatorProtocol: Coordinator {
    func showRecordPageViewController()
}

final class RecordCoordinator: RecordCoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var delegate: CoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.isNavigationBarHidden = false
    }
    
    func start() {
        showRecordPageViewController()
    }
    
    func showRecordPageViewController() {
        let mainRepository = DefaultRecordRepository(
            realtimeDatabaseNetworkService: DefaultRealtimeDatabaseNetworkService()
        )
        let mainUseCase = DefaultRecordMainViewUseCase(repository: mainRepository)
        let mainViewModel = RecordMainViewModel(useCase: mainUseCase)
        
        let mapRepository = DefaultRecordRepository(
            realtimeDatabaseNetworkService: DefaultRealtimeDatabaseNetworkService()
        )
        let mapUseCase = DefaultRecordMapViewUseCase(repository: mapRepository)
        let mapViewModel = RecordMapViewModel(useCase: mapUseCase)
        
        let viewController = RecordPageViewController(mainViewModel: mainViewModel, mapViewModel: mapViewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
