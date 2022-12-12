//
//  MyPageCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit
import SafariServices

protocol MyPageCoordinatorProtocol: Coordinator {
    func showMyPageViewController()
    func showBadgeViewController(allBadges: [Badge], ownedBadges: [Badge])
    func showMyInfoEditViewController(user: User, ownedBadges: [Badge])
    func showCharacterSelectViewController(myInfoEditViewModel: MyInfoEditViewModel, ownedBadges: [Badge])
    func showSafariViewController(stringURL: String)
}

final class MyPageCoordinator: MyPageCoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var delegate: CoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.isNavigationBarHidden = false
    }
    
    func start() {
        showMyPageViewController()
    }
    
    func showMyPageViewController() {
        let networkService = DefaultRealtimeDatabaseNetworkService()
        let keychainService = DefaultKeychainService()
        let authService = DefaultAuthService()
        let userRepository = DefaultUserRepository(realtimeDataBaseService: networkService,
                                                   keychainService: keychainService,
                                                   authService: authService)
        let badgeRepository = DefaultBadgeRepository(realTimeDatabaseNetworkService: networkService)
        let useCase = DefaultMyPageUseCase(userRepository: userRepository, badgeRepository: badgeRepository)
        let viewModel = MyPageViewModel(coordinator: self, useCase: useCase)
        let viewController = MyPageViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showBadgeViewController(allBadges: [Badge], ownedBadges: [Badge]) {
        let viewModel = BadgeViewModel(
                     allBadges: allBadges,
                     ownedBadges: ownedBadges)
        let viewController = BadgeViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showMyInfoEditViewController(user: User, ownedBadges: [Badge]) {
        let networkService = DefaultRealtimeDatabaseNetworkService()
        let keychainService = DefaultKeychainService()
        let authService = DefaultAuthService()
        let userRepository = DefaultUserRepository(realtimeDataBaseService: networkService,
                                                   keychainService: keychainService,
                                                   authService: authService)
        let useCase = DefaultMyInfoEditUseCase(userRepository: userRepository)
        let viewModel = MyInfoEditViewModel(coordinator: self,
                                            useCase: useCase,
                                            user: user,
                                            ownedBadges: ownedBadges)
        let viewController = MyInfoEditViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showCharacterSelectViewController(myInfoEditViewModel: MyInfoEditViewModel,
                                           ownedBadges: [Badge]) {
        let viewModel = CharacterSelectViewModel(coordinator: self,
                                                 delegate: myInfoEditViewModel,
                                                 ownedBadges: ownedBadges)
        let viewController = CharacterSelectViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showSafariViewController(stringURL: String) {
        guard let url = URL(string: stringURL) else { return }
        let viewController = SFSafariViewController(url: url)
        navigationController.present(viewController, animated: true)
    }
}

extension MyPageCoordinator: CoordinatorDelegate {
    func didFinished(childCoordinator: Coordinator) {
        removeChildCoordinator(coordinator: childCoordinator)
        navigationController.viewControllers.removeLast()
    }
}
