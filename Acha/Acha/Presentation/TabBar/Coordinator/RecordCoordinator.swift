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
        @DIContainer.Resolve(RecordMainViewUseCase.self)
        var mainUseCase: RecordMainViewUseCase
        let mainViewModel = RecordMainViewModel(useCase: mainUseCase)
        
        @DIContainer.Resolve(RecordMapViewUseCase.self)
        var mapUseCase: RecordMapViewUseCase
        let mapViewModel = RecordMapViewModel(useCase: mapUseCase)
        
        let viewController = RecordPageViewController(
            recordMainViewController: RecordMainViewController(viewModel: mainViewModel),
            recordMapViewController: RecordMapViewController(viewModel: mapViewModel)
        )
        navigationController.pushViewController(viewController, animated: true)
    }
}
