//
//  MultiGameCoordinator.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import UIKit

protocol MultiGameCoordinatorProtocol: Coordinator {
    func showMultiGameRoomViewController(roomID: String)
    func showMultiGameViewController(roomID: String)
    func showMultiGameChatViewController(roomID: String)
}

final class MultiGameCoordinator: MultiGameCoordinatorProtocol {
    
    func start() {}
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    var delegate: CoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.isNavigationBarHidden = true 
        childCoordinators = []
    }
    
    func start(gameID: String) {
        navigationController.navigationBar.topItem?.title = ""
        navigationController.navigationBar.tintColor = .pointDark
        showMultiGameRoomViewController(roomID: gameID)
    }
    
    func showMultiGameRoomViewController(roomID: String) {
        
        @DIContainer.Resolve(MultiGameRoomUseCase.self)
        var useCase: MultiGameRoomUseCase
//        let useCase = DependenciesContainer.shared.resolve(MultiGameRoomUseCase.self)
        let viewModel = MultiGameRoomViewModel(
            coordinator: self,
            useCase: useCase,
            roomID: roomID
        )
        let viewController = MultiGameRoomViewController(
            viewModel: viewModel,
            roomID: roomID
        )
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showMultiGameViewController(roomID: String) {
        @DIContainer.Resolve(MultiGameUseCase.self)
        var useCase: MultiGameUseCase
//        let useCase = DependenciesContainer.shared.resolve(MultiGameUseCase.self)
        let viewModel = MultiGameViewModel(
            coordinator: self,
            useCase: useCase,
            roomId: roomID
        )
        let viewController = MultiGameViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        navigationController.tabBarController?.tabBar.isHidden = true
    }
    
    func showMultiGameChatViewController(roomID: String) {
        let useCase = DiContainerManager.makeMultiGameChatUseCase()
        let viewModel = MultiGameChatViewModel(
            coordinator: self,
            roomID: roomID,
            useCase: useCase
        )
        let viewController = MultiGameChatViewController(viewModel: viewModel, roomID: roomID)
        
        let transiton = CATransition()
        transiton.type = CATransitionType.moveIn
        transiton.subtype = CATransitionSubtype.fromRight
        transiton.duration = 0.8
        transiton.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        navigationController.isNavigationBarHidden = false
        navigationController.view.layer.add(transiton, forKey: nil)
        navigationController.pushViewController(viewController, animated: true)
    }
}
