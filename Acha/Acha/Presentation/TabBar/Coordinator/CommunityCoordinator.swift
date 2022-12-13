//
//  CommunityCoordinator.swift
//  Acha
//
//  Created by 배남석 on 2022/11/14.
//

import UIKit

protocol CommunityCoordinatorProtocol: Coordinator {
    func showCommunityMainViewController()
    func showCommunityPostWriteViewController(post: Post?)
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
        let communityRepository = DefaultCommunityRepository(realtimeService: DefaultRealtimeDatabaseNetworkService(),
                                                    storageService: DefaultFirebaseStorageNetworkService(),
                                                    imageCacheService: DefaultImageCacheService())
        let useCase = DefaultCommunityMainUseCase(communityRepository: communityRepository)
        let viewModel = CommunityMainViewModel(useCase: useCase,
                                               coordinator: self)
        let viewController = CommunityMainViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showCommunityPostWriteViewController(post: Post? = nil) {
        let realTimeNetworkService = DefaultRealtimeDatabaseNetworkService()
        let userRepository = DefaultUserRepository(realtimeDataBaseService: realTimeNetworkService,
                                                   keychainService: DefaultKeychainService(),
                                                   authService: DefaultAuthService())
        let communityRepository = DefaultCommunityRepository(realtimeService: realTimeNetworkService,
                                                             storageService: DefaultFirebaseStorageNetworkService(),
                                                             imageCacheService: DefaultImageCacheService())
        let useCase = DefaultCommunityPostWriteUseCase(post: post,
                                                       communityRepository: communityRepository,
                                                       userRepository: userRepository)
        let viewModel = CommunityPostWriteViewModel(useCase: useCase,
                                                    coordinator: self)
        let viewController = CommunityPostWriteViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showCommunityDetailViewController(postID: Int) {
        let realTimeNetworkService = DefaultRealtimeDatabaseNetworkService()
        let userRepository = DefaultUserRepository(realtimeDataBaseService: realTimeNetworkService,
                                                   keychainService: DefaultKeychainService(),
                                                   authService: DefaultAuthService())
        let communityRepository = DefaultCommunityRepository(realtimeService: realTimeNetworkService,
                                                             storageService: DefaultFirebaseStorageNetworkService(),
                                                             imageCacheService: DefaultImageCacheService())
        
        let useCase = DefaultCommunityDetailUseCase(postID: postID,
                                                    communityRepository: communityRepository,
                                                    userRepository: userRepository)
        let viewModel = CommunityDetailViewModel(useCase: useCase,
                                                 coordinator: self)
        let viewController = CommunityDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func popLastViewController() {
        navigationController.popViewController(animated: true)
    }
}
