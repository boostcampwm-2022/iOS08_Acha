//
//  AuthCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit
import FirebaseAuth
import Firebase

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
        self.navigationController.isNavigationBarHidden = true 
    }
    
    func start() {
        connectLoginCoordinator()
    }
    
    func connectLoginCoordinator() {
        let coordinator = LoginCoordinator(navigationController: navigationController)
        appendChildCoordinator(coordinator: coordinator)
        coordinator.delegate = self
        coordinator.loginDelegate = self
        coordinator.start()
    }
    
    func connectSignupCoordinator() {
        let coordinator = SignupCoordinator(navigationController: navigationController)
        appendChildCoordinator(coordinator: coordinator)
        coordinator.delegate = self
        coordinator.signupDelegate = self
        coordinator.start()
    }
}

extension AuthCoordinator: CoordinatorDelegate {
    func didFinished(childCoordinator: Coordinator) {
        removeChildCoordinator(coordinator: childCoordinator)
        navigationController.viewControllers = []
        delegate?.didFinished(childCoordinator: self)
    }
}

extension AuthCoordinator: LoginCoordinatorDelegate, SginupCoordinatorDelegate {
    func switchToSignup() {
        resetViews()
        connectSignupCoordinator()
    }
    
    func switchToLogin() {
        resetViews()
        connectLoginCoordinator()
    }
    
    private func resetViews() {
        navigationController.viewControllers = []
        removeAllChildCoordinator()
    }
}
