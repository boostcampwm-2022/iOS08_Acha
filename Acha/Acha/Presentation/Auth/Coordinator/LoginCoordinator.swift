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
        let provider = AuthProvider()
        let repository = LogInRepository(provider: provider)
        let useCase = LoginUseCase(repository: repository)
        let viewModel = LoginViewModel(
            coordinator: self,
            useCase: useCase
        )
        let viewController = LoginViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        self.navigationController.isNavigationBarHidden = true
    }
    
    func showSignupViewController() {
        loginDelegate?.switchToSignup()
    }
    
    /// snapkit 에서 superview 를 찾을 수 없다는 오류로 인해서 강제적으로 네비게이션 컨트롤러를
    /// 정리해 줘야 되서 만든 함수 입니다.
    private func navigationControllerRefactoring() {
        var viewControllers = navigationController.viewControllers
        viewControllers.remove(at: viewControllers.count-2)
    }
}
#warning("didFinished 제거")
extension LoginCoordinator: CoordinatorDelegate {
    func didFinished(childCoordinator: Coordinator) {
        showLoginViewController()
    }
}
