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
    }
    
    func start() {
        showMyPageViewController()
    }
    
    func showMyPageViewController() {
        let viewController = MyPageViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
}
