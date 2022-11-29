//
//  CommunityCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

protocol CommunityCoordinatorProtocol: Coordinator {
    func showCommunityViewController()
}

final class CommunityCoordinator: CommunityCoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var delegate: CoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.isNavigationBarHidden = false
    }
    
    func start() {
//        showCommunityViewController()
        showCommunityPostViewController()
    }
    
    func showCommunityViewController() {
        let viewController = CommunityViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showCommunityPostViewController() {
          let viewController = CommunityPostViewController()
          navigationController.pushViewController(viewController, animated: true)
      }
}
