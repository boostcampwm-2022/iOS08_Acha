//
//  HomeCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

protocol HomeCoordinatorProtocol: Coordinator {
    func showHomeViewController()
    func connectSingleGameFlow()
    func connectMultiGameFlow(gameID: String)
}

final class HomeCoordinator: HomeCoordinatorProtocol {
    weak var delegate: CoordinatorDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var tabBarController: UITabBarController?
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.isNavigationBarHidden = false
    }
    
    convenience init(navigationController: UINavigationController,
                     tabBarController: UITabBarController) {
        self.init(navigationController: navigationController)
        self.tabBarController = tabBarController
    }
    
    func start() {
//        showHomeViewController()
        showChatViewController()
    }
    
    func showHomeViewController() {
        let useCase = DiContainerManager.makeDefaultHomeUseCase()
        let viewModel = HomeViewModel(
            coordinator: self,
            useCase: useCase
        )
        let viewController = HomeViewController(viewModel: viewModel)
        navigationController.navigationBar.isHidden = false
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showChatViewController() {
        let roomID = "12345678"
        let useCase = DefaultMultiGameChatUseCase(roomRepository: DiContainerManager.makeDefaultGameRoomRepository(),
                                                  userRepository: DiContainerManager.makeDefaultUserRepository())
        let viewModel = MultiGameChatViewModel(roomID: roomID, useCase: useCase)
        let viewController = MultiGameChatViewController(viewModel: viewModel, roomID: roomID)
        navigationController.navigationBar.isHidden = false
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func connectSingleGameFlow() {
        tabBarController?.tabBar.isHidden = true
        
        let coordinator = SingleGameCoordinator(navigationController: navigationController)
        coordinator.delegate = self
        appendChildCoordinator(coordinator: coordinator)
        coordinator.start()
    }
    
    func connectMultiGameFlow(gameID: String) {
        let coordinator = MultiGameCoordinator(navigationController: navigationController)
        coordinator.delegate = self
        appendChildCoordinator(coordinator: coordinator)
        coordinator.start(gameID: gameID)
    }
}

extension HomeCoordinator: CoordinatorDelegate {
    func didFinished(childCoordinator: Coordinator) {
        navigationController.viewControllers.last?.dismiss(animated: true)
        removeChildCoordinator(coordinator: childCoordinator)
        navigationController.viewControllers.removeAll(where: { !($0 is HomeViewController) })
        tabBarController?.tabBar.isHidden = false
    }
}
