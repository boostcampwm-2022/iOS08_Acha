//
//  LoginCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit
import RxSwift

protocol LoginCoordinatorProtocol: Coordinator {
    func showLoginViewController()
    func showSignupViewController()
}

protocol LoginCoordinatorDelegate: AnyObject {
    func switchToSignup()
}

final class LoginCoordinator: LoginCoordinatorProtocol {
    
    weak var delegate: CoordinatorDelegate?
    weak var loginDelegate: LoginCoordinatorDelegate?
    
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showLoginViewController()
    }
    func showLoginViewController() {
        @DIContainer.Resolve(LoginUseCase.self)
        var useCase: LoginUseCase
        let viewModel = LoginViewModel(
            coordinator: self,
            useCase: useCase
        )
        let viewController = LoginViewController(viewModel: viewModel)
        let transiton = CATransition()
        transiton.type = .moveIn
        transiton.subtype = .fromLeft
        transiton.duration = 0.3
        navigationController.view.layer.add(transiton, forKey: "login")
        navigationController.pushViewController(viewController, animated: true)
        self.navigationController.isNavigationBarHidden = true
    }
    
    func showSignupViewController() {
        loginDelegate?.switchToSignup()
    }

}
#warning("didFinished 제거")
extension LoginCoordinator: CoordinatorDelegate {
    func didFinished(childCoordinator: Coordinator) {
        showLoginViewController()
    }
}
