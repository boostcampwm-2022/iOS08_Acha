//
//  SignupCoordinator .swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

protocol SignupCoordinatorProtocol: Coordinator {
    func showSignupViewController()
    func showLoginViewController()
}

protocol SginupCoordinatorDelegate: AnyObject {
    func switchToLogin()
}

final class SignupCoordinator: SignupCoordinatorProtocol {
    
    weak var delegate: CoordinatorDelegate?
    weak var signupDelegate: SginupCoordinatorDelegate?
    
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showSignupViewController()
    }
    
    func showSignupViewController() {
        let useCase = DefaultSignUpUsecase(repository: DiContainerManager.makeDefaultUserRepository())
        let viewModel = SignUpViewModel(
            coordinator: self,
            useCase: useCase
        )
        let transiton = CATransition()
        transiton.type = .moveIn
        transiton.subtype = .fromRight
        transiton.duration = 0.3
        navigationController.view.layer.add(transiton, forKey: "signup")
        let viewController = SignupViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showLoginViewController() {
        signupDelegate?.switchToLogin()
    }

}
