//
//  RecordCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

final class RecordCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        print("record")
    }
    
}
