//
//  AuthCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

protocol AuthCoordinatorProtocol: Coordinator {
    func connectLoginCoordinator()
    func connectSignupCoordinator()
}

final class AuthCoordinator: AuthCoordinatorProtocol {
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var delegate: CoordinatorDelegate?
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        connectLoginCoordinator()
    }
    
    func connectLoginCoordinator() {
        let coordinator = LoginCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
        coordinator.delegate = self
        coordinator.start()
    }
    
    func connectSignupCoordinator() {
        let coordinator = SignupCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
        coordinator.delegate = self
        coordinator.start()
    }
}

extension AuthCoordinator: CoordinatorDelegate {
    func didFinished(childCoordinator: Coordinator) {
        removeChildCoordinator(coordinator: childCoordinator)
        
        switch childCoordinator {
        case is LoginCoordinator:
            connectSignupCoordinator()
        case is SignupCoordinator:
            connectLoginCoordinator()
        default:
            break
        }
    }
}
