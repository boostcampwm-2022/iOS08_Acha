//
//  CommunityPostWriteViewModel.swift
//  Acha
//
//  Created by 배남석 on 2022/12/06.
//

import Foundation
import RxSwift
import RxRelay

final class CommunityPostWriteViewModel: BaseViewModel {
    struct Input {
        var viewWillAppearEvent: Observable<Void>
        var rightButtonTapped: Observable<(String, Image?)>
    }
    
    struct Output {
        var post = PublishRelay<Post>()
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
        
        input.viewWillAppearEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.useCase.confirmHavePost()
                    .subscribe(onSuccess: { post in
                        if let post {
                            output.post.accept(post)
                        }
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
        
        input.rightButtonTapped
            .subscribe(onNext: { [weak self] (postContent, image) in
                guard let self else { return }
                self.useCase.uploadPost(postContent: postContent, image: image)
                    .subscribe(onSuccess: { _ in
                        self.coordinator.popLastViewController()
                    })
                    .disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
        
        return output
    }
}
