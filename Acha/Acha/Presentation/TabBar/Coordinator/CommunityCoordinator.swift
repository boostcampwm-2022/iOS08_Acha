//
//  CommunityCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

protocol CommunityCoordinatorProtocol: Coordinator {
    func showCommunityMainViewController()
    func showCommunityPostWriteViewController()
    func showCommunityDetailViewController(postID: Int)
}

final class CommunityCoordinator: CommunityCoordinatorProtocol {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var delegate: CoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.isNavigationBarHidden = false
    }
    
    func start() {
        showCommunityMainViewController()
    }
    
    func showCommunityMainViewController() {
        let repository = DefaultCommunityRepository(realtimeService: DefaultRealtimeDatabaseNetworkService())
        let useCase = DefaultCommunityMainUseCase(repository: repository)
        let viewModel = CommunityMainViewModel(useCase: useCase,
                                               coordinator: self)
        let viewController = CommunityMainViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showCommunityPostWriteViewController() {
        let repository = DefaultCommunityRepository(realtimeService: DefaultRealtimeDatabaseNetworkService(),
                                                    storageService: DefaultFirebaseStorageNetworkService())
        let useCase = DefaultCommunityPostWriteUseCase(repository: repository)
        let viewModel = CommunityPostWriteViewModel(useCase: useCase,
                                                    coordinator: self)
        let viewController = CommunityPostWriteViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showCommunityDetailViewController(postID: Int) {
        let repository = DefaultCommunityRepository(realtimeService: DefaultRealtimeDatabaseNetworkService())
        let useCase = DefaultCommunityDetailUseCase(postID: postID, repository: repository)
        let viewModel = CommunityDetailViewModel(useCase: useCase)
        let viewController = CommunityDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
