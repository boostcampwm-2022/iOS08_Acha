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
        showRecordViewController()
    }
    
    func showRecordViewController() {
        let useCase = DefaultRecordViewUseCase()
        let viewModel = RecordViewModel(useCase: useCase)
        let viewController = RecordViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
}
