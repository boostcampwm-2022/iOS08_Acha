//
//  AppCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

protocol AppCoordinatorProtocol: Coordinator {
    func connectAuth()
    func connectTabBar()
}

final class AppCoordinator: AppCoordinatorProtocol {
    
    var navigationController: UINavigationController
    var childCoordinators = [Coordinator]()
    weak var delegate: CoordinatorDelegate?
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        if (try? KeyChainManager.get()) == nil {
            connectAuth()
        } else {
            connectTabBar()
        }
    }
    
    func connectAuth() {
        let coordinator = AuthCoordinator(navigationController: navigationController)
        coordinator.start()
        coordinator.delegate = self
        appendChildCoordinator(coordinator: coordinator)
    }
    
    func connectTabBar() {
        let coordinator = TabBarCoordinator(navigationController: navigationController)
        coordinator.start()
        coordinator.delegate = self
        appendChildCoordinator(coordinator: coordinator)
    }
}

extension AppCoordinator: CoordinatorDelegate {
    func didFinished(childCoordinator: Coordinator) {
        removeAllChildCoordinator()
        switch childCoordinator {
        case is AuthCoordinator:
            connectTabBar()
        case is TabBarCoordinator:
            connectAuth()
        default:
            break
        }
    }
}
