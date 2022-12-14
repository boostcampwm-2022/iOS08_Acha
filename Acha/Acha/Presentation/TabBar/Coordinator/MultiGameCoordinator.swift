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
        childCoordinators = []
    }
    
    func start(gameID: String) {
        showMultiGameRoomViewController(roomID: gameID)
    }
    
    func showMultiGameRoomViewController(roomID: String) {
        @DIContainer.Resolve(MultiGameRoomUseCase.self)
        var useCase: MultiGameRoomUseCase
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
        @DIContainer.Resolve(MultiGameChatUseCase.self)
        var useCase: MultiGameChatUseCase
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
