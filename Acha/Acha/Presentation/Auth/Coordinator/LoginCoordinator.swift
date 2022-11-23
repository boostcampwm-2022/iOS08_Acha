//
//  LoginCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

protocol LoginCoordinatorProtocol: Coordinator {
    func showLoginViewController()
    func connectSignupFlow()
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
        let useCase = AuthUseCase()
        let repository = AuthRepository()
        let viewModel = LoginViewModel(
            coordinator: self,
            useCase: useCase,
            repository: repository
        )
        let viewController = LoginViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        self.navigationController.isNavigationBarHidden = true
    }
    
    func connectSignupFlow() {
        let coordinator = SignupCoordinator(navigationController: navigationController)
        appendChildCoordinator(coordinator: coordinator)
        coordinator.delegate = self
        coordinator.start()
    }
}

extension LoginCoordinator: CoordinatorDelegate {
    func didFinished(childCoordinator: Coordinator) {
        childCoordinator.popSelfFromNavigatonController()
    }
}
