//
//  RecordCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

protocol RecordCoordinatorProtocol: Coordinator {
    func showRecordViewController()
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
//        showRecordViewController()
    }
    
    func showRecordPageViewController() {
        let mainUseCase = DefaultRecordMainViewUseCase()
        let mainViewModel = RecordMainViewModel(useCase: mainUseCase)
        
        let mapUseCase = DefaultRecordMapViewUseCase()
        let mapViewModel = RecordMapViewModel(useCase: mapUseCase)
        let viewController = RecordPageViewController(mainViewModel: mainViewModel, mapViewModel: mapViewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showRecordViewController() {
        let useCase = DefaultRecordMainViewUseCase()
        let viewModel = RecordMainViewModel(useCase: useCase)
        let viewController = RecordMainViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
}
