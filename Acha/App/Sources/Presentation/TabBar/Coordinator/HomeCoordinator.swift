//
//  HomeCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

protocol HomeCoordinatorProtocol: Coordinator {
    func showHomeViewController()
    func connectSingleGameFlow()
}

final class HomeCoordinator: HomeCoordinatorProtocol {
    var delegate: CoordinatorDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var tabBarController: UITabBarController?
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.isNavigationBarHidden = false
    }
    
    convenience init(navigationController: UINavigationController,
                     tabBarController: UITabBarController) {
        self.init(navigationController: navigationController)
        self.tabBarController = tabBarController
    }
    
    func start() {
        showHomeViewController()
    }
    
    func showHomeViewController() {
        let viewModel = HomeViewModel(coordinator: self)
        let viewController = HomeViewController(viewModel: viewModel)
        navigationController.navigationBar.isHidden = false
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func connectSingleGameFlow() {
        tabBarController?.tabBar.isHidden = true
        
        let coordinator = SingleGameCoordinator(navigationController: navigationController)
        coordinator.delegate = self
        appendChildCoordinator(coordinator: coordinator)
        coordinator.start()
    }
}

extension HomeCoordinator: CoordinatorDelegate {
    func didFinished(childCoordinator: Coordinator) {
        removeChildCoordinator(coordinator: childCoordinator)
        navigationController.viewControllers.removeAll()
        tabBarController?.tabBar.isHidden = false
        showHomeViewController()
    }
}
