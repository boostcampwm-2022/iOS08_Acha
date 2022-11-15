//
//  TabBarCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

protocol TabBarCoordinatorProtocol: Coordinator {
    var tabBarController: UITabBarController {get set}
    
    func configureTabBarController()
    func createTabNavigationController(tabBarType type: TabBarType) -> UINavigationController
    func tabBarCoordinatorAppend(type: TabBarType, navigationController: UINavigationController)
    
}
final class TabBarCoordinator: TabBarCoordinatorProtocol {
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var tabBarController = UITabBarController()
    weak var delegate: CoordinatorDelegate?
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.isNavigationBarHidden = true
    }
    
    func start() {
        configureTabBarController()
    }
    
    func configureTabBarController() {
        let navigationControllers = TabBarType.allCases.map {
            createTabNavigationController(tabBarType: $0)
        }
        tabBarController.viewControllers = navigationControllers
        navigationController.viewControllers = [tabBarController]
        
        tabBarController.tabBar.backgroundColor = UIColor(named: "PointLightColor")
        tabBarController.tabBar.tintColor = .white
    }
    
    func createTabNavigationController(tabBarType type: TabBarType) -> UINavigationController {
        let tabNavigationController = UINavigationController()
        tabBarCoordinatorAppend(type: type, navigationController: tabNavigationController)
        tabNavigationController.tabBarItem = UITabBarItem(title: nil,
                                                       image: UIImage(systemName: type.iconImage),
                                                       selectedImage: UIImage(systemName: type.selectedIconImage))
        return tabNavigationController
    }
    
    func tabBarCoordinatorAppend(type: TabBarType, navigationController: UINavigationController) {
        var coordinator: Coordinator
        switch type {
        case .home:
            coordinator = HomeCoordinator(navigationController: navigationController)
        case .record:
            coordinator = RecordCoordinator(navigationController: navigationController)
        case .community:
            coordinator = CommunityCoordinator(navigationController: navigationController)
        case .myPage:
            coordinator = MyPageCoordinator(navigationController: navigationController)
        }
        coordinator.delegate = self
        appendChildCoordinator(coordinator: coordinator)
        coordinator.start()
    }
}

extension TabBarCoordinator: CoordinatorDelegate {
    func didFinished(childCoordinator: Coordinator) {
        removeChildCoordinator(coordinator: childCoordinator)
    }
}
