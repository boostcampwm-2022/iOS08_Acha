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
    
    func start()
    /// 특정 자식 코디네이터 삭제
    func removeChildCoordinator(coordinator: Coordinator)
    /// 자식 코디네이터 추가 
    func appendChildCoordinator(coordinator: Coordinator)
    /// 자식 코디네이터 전부 제거
    func removeAllChildCoordinator()
    /// 자기 자신 컨트롤러를 네비게이션 컨트롤러에서 제거
    func popSelfFromNavigatonController()
}

extension Coordinator {
    func removeChildCoordinator(coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
    
    func appendChildCoordinator(coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeAllChildCoordinator() {
        childCoordinators = []
    }
    
    func popSelfFromNavigatonController() {
        navigationController.viewControllers.removeLast()
    }
}

protocol CoordinatorDelegate: AnyObject {
    func didFinished(childCoordinator: Coordinator)
}
