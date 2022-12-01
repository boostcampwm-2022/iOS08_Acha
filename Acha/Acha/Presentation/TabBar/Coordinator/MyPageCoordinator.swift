//
//  MyPageCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

protocol MyPageCoordinatorProtocol: Coordinator {
    func showMyPageViewController()
}

final class MyPageCoordinator: Coordinator {
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
        let userRepository = DefaultUserRepository(realTimeDatabaseNetworkService: networkService)
        let badgeRepository = DefaultBadgeRepository2(realTimeDatabaseNetworkService: networkService)
        let useCase = DefaultMyPageUseCase(userRepository: userRepository, badgeRepository: badgeRepository)
        let viewModel = MyPageViewModel(coordinator: self, useCase: useCase)
        let viewController = MyPageViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showBadgeViewController(allBadges: [Badge], ownedBadges: [Badge]) {
        let viewModel = BadgeViewModel()
        let viewController = BadgeViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showMyInfoEditViewController() {
        let viewController = MyInfoEditViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
}
