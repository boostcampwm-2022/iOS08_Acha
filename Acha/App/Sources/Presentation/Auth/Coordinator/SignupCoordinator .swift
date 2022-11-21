//
//  SignupCoordinator .swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

protocol SignupCoordinatorProtocol: Coordinator {
    func showSignupViewController()
}

final class SignupCoordinator: SignupCoordinatorProtocol {
    var delegate: CoordinatorDelegate?
    
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showSignupViewController()
    }
    
    func showSignupViewController() {
        let viewController = SignupViewController()
        navigationController.pushViewController(viewController, animated: true)
    }

}
