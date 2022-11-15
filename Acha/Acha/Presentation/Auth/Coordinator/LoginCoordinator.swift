//
//  LoginCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

protocol LoginCoordinatorProtocol: Coordinator {
    func showLoginViewController()
}

final class LoginCoordinator: LoginCoordinatorProtocol {
    var delegate: CoordinatorDelegate?
    
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showLoginViewController()
    }
    func showLoginViewController() {
        let viewController = LoginViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
}
