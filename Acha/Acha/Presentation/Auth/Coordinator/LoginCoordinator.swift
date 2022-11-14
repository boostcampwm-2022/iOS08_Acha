//
//  LoginCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

final class LoginCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
    }
    
    func didFinished(coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
    
}
