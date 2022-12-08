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
    func showMyInfoEditViewController()
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
    
    func showMyInfoEditViewController() {
        let viewController = MyInfoEditViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    #warning("여기서 사파리 뷰컨 띄워주는게 맞겠죠?")
    func showSafariViewController(stringURL: String) {
        guard let url = URL(string: stringURL)
        else { return }
        let safariVC = SFSafariViewController(url: url)
        navigationController.present(safariVC, animated: true)
    }
}
