//
//  HomeCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit 

protocol HomeCoordinatorProtocol: Coordinator {
    func showHomeViewController()
    func showSingleGamePlayViewController()
}

final class HomeCoordinator: HomeCoordinatorProtocol {
    var delegate: CoordinatorDelegate?
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.isNavigationBarHidden = false 
    }
    
    func start() {
        showSingleGamePlayViewController()
    }
    
    func showHomeViewController() {
        let viewController = HomeViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showSingleGamePlayViewController() {
        let viewModel = SingleGamePlayViewModel(coordinator: self)
        let viewController = SingleGamePlayViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
}
