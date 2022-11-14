//
//  TabBarCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

final class TabBarCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    let tabBarController = UITabBarController()
    weak var delegate: ChildCoordinatorPopable?
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
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
        
        tabBarController.tabBar.backgroundColor = .blue
        tabBarController.tabBar.tintColor = .white
    }
    
    func createTabNavigationController(tabBarType type: TabBarType) -> UINavigationController {
        let tabNavigationController = UINavigationController()
        tabNavigationController.tabBarItem = UITabBarItem(title: nil,
                                                       image: UIImage(systemName: type.iconImage),
                                                       selectedImage: UIImage(systemName: type.selectedIconImage))
        connect(type: type, navigationController: tabNavigationController)
        return tabNavigationController
    }
    
    func connect(type: TabBarType, navigationController: UINavigationController) {
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
        coordinator.start()
        childCoordinators.append(coordinator)
    }
}
