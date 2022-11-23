//
//  MultiGameCoordinator.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import UIKit

protocol MultiGameCoordinatorProtocol: Coordinator {
    func showMultiGameRoomViewController(gameID: String)
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
        showMultiGameRoomViewController(gameID: gameID)
    }
    
    func showMultiGameRoomViewController(gameID: String) {
        let provider = MultiGameRoomProvider()
        let useCase = MultiGameRoomUseCase(repository: provider)
        let viewModel = MultiGameRoomViewModel(
            coordinator: self,
            useCase: useCase
        )
        let viewController = MultiGameRoomViewController(viewModel: viewModel)
        viewController.qrCodeImageView.image = gameID.generateQRCode(from: gameID)!
        navigationController.pushViewController(viewController, animated: true)
    }
}
