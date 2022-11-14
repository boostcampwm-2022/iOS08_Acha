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
    
    init(navigationController: UINavigationController)
    
    func start()
    
}

protocol ChildCoordinatorPopable: AnyObject {
    /// 자식 코디네이터 해제
    func didFinished(childCoordinator: Coordinator)
}
