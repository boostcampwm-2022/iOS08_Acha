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

final class LoginCoordinator: LoginCoordinatorProtocol, SignupCoordinatorProtocol {
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
    
    func showSignupViewController() {
        let useCase = AuthUseCase()
        let repository = AuthRepository()
        let viewModel = SignUpViewModel(
            coordinator: self,
            useCase: useCase,
            repository: repository
        )
        let viewController = SignupViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        self.navigationController.isNavigationBarHidden = false
    }
}
