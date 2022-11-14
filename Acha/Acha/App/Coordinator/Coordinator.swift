//
//  Coordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController {get set}
    var childCoordinators: [Coordinator] {get set}
    var delegate: CoordinatorDelegate? {get set}
    
    init(navigationController: UINavigationController)
    
    func removeChildCoordinator(coordinator: Coordinator)
    func start()
    func appendChildCoordinator(coordinator: Coordinator)
}

extension Coordinator {
    func removeChildCoordinator(coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
    
    func appendChildCoordinator(coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
}

protocol CoordinatorDelegate: AnyObject {
    func didFinished(childCoordinator: Coordinator)
}
