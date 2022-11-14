//
//  HomeCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit 

final class HomeCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var delegate: ChildCoordinatorPopable?
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = HomeViewController()
//        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: false)
    }
    
}
