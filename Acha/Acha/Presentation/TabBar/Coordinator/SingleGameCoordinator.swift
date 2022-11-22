//
//  SingleGameCoordinator.swift
//  Acha
//
//  Created by 조승기 on 2022/11/16.
//

import UIKit

protocol SingleGameCoordinatorProtocol: Coordinator {
    func showSelectMapViewController()
    func showSingleGamePlayViewController(selectedMap: Map)
}

final class SingleGameCoordinator: SingleGameCoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    var delegate: CoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        childCoordinators = []
    }
    
    func start() {
        showSelectMapViewController()
    }
    
    func showSelectMapViewController() {
        let viewModel = SelectMapViewModel(coordinator: self)
        let viewController = SelectMapViewController(viewModel: viewModel)
        navigationController.navigationBar.isHidden = true
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showSingleGamePlayViewController(selectedMap: Map) {
        let viewModel = SingleGameViewModel(coordinator: self, map: selectedMap)
        let viewController = SingleViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showSingleGameOverViewController(record: AchaRecord, mapName: String) {
        let viewModel = GameOverViewModel(coordinator: self, record: record, mapName: mapName)
        let viewController = GameOverViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showInGameRecordViewController() {
        let viewController = InGameRecordViewController()
        viewController.modalPresentationStyle = .pageSheet
        self.navigationController.viewControllers.last?.present(viewController, animated: true)
    }
    
    func showInGameRankViewController(map: Map) {
        let viewModel = InGameRankingViewModel(map: map)
        let viewController = InGameRankingViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .pageSheet
        self.navigationController.viewControllers.last?.present(viewController, animated: true)
    }
}
