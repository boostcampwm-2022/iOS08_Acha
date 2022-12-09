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
        // 로그인 여부 따라 로직 분리
//        connectTabBar()
        connectAuth()
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
    #warning("append 제거")
    func didFinished(childCoordinator: Coordinator) {
        removeAllChildCoordinator()
        switch childCoordinator {
        case is AuthCoordinator:
            appendChildCoordinator(coordinator: childCoordinator)
            connectTabBar()
        case is TabBarCoordinator:
            appendChildCoordinator(coordinator: childCoordinator)
            connectAuth()
        default:
            break
        }
    }
}
