//
//  MultiGameCoordinator.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import UIKit

protocol MultiGameCoordinatorProtocol: Coordinator {
    func showMultiGameRoomViewController(roomID: String)
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
    }
    
    func showMultiGameRoomViewController(roomID: String) {
        let provider = FBRealTimeDB()
        let datasource = MultiGameRoomDataSource(provider: provider)
        let repository = MultiGameRoomRepository(dataSource: datasource)
        let useCase = MultiGameRoomUseCase(repository: repository)
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
}
