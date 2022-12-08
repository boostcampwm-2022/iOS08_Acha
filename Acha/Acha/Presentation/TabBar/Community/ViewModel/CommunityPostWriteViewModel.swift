//
//  CommunityPostWriteViewModel.swift
//  Acha
//
//  Created by 배남석 on 2022/12/06.
//

import Foundation
import RxSwift

final class CommunityPostWriteViewModel: BaseViewModel {
    struct Input {
        var rightButtonTapped: Observable<(Post, Image?)>
    }
    
    struct Output {
        
    }
    
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    private let useCase: CommunityPostWriteUseCase
    private let coordinator: CommunityCoordinator
    
    // MARK: - Lifecycles
    init(useCase: CommunityPostWriteUseCase, coordinator: CommunityCoordinator) {
        self.useCase = useCase
        self.coordinator = coordinator
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.rightButtonTapped
            .subscribe(onNext: { [weak self] (post, image) in
                guard let self else { return }
                self.useCase.uploadPost(post: post, image: image)
                self.coordinator.navigationController.popViewController(animated: true)
            }).disposed(by: disposeBag)
        
        return output
    }
}
