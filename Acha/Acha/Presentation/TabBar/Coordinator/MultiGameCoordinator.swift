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
        showMultiGameRoomViewController(roomID: gameID)
//        showMultiGameViewController(roomID: "weat")
    }
    
    func showMultiGameRoomViewController(roomID: String) {
        
        let useCase = DefaultMultiGameRoomUseCase(repository: DiContainerManager.makeDefaultGameRoomRepository())
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
        
        let useCase = DiContainerManager.makeMultiGameUseCase()
        let viewModel = MultiGameViewModel(
            coordinator: self,
            useCase: useCase,
            roomId: roomID
        )
        let viewController = MultiGameViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        navigationController.tabBarController?.tabBar.isHidden = true
    }
}
