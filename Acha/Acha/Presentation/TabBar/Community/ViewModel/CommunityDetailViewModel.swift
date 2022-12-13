//
//  CommunityDetailViewModel.swift
//  Acha
//
//  Created by 배남석 on 2022/12/05.
//

import Foundation
import RxSwift
import RxRelay

final class CommunityDetailViewModel: BaseViewModel {
    struct Input {
        var viewWillAppearEvent: Observable<Void>
        var commentRegisterButtonTapEvent: Observable<Comment>
        var postModifyButtonTapEvent: Observable<Post>
        var postDeleteButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        var post = PublishRelay<(post: Post, isMine: Bool)>()
        var user = PublishRelay<User>()
        var commentWriteSuccess = PublishRelay<Void>()
    }
    
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    private let useCase: CommunityDetailUseCase
    private weak var coordinator: CommunityCoordinator?
    
    // MARK: - Lifecycles
    init(useCase: CommunityDetailUseCase,
         coordinator: CommunityCoordinator) {
        self.useCase = useCase
        self.coordinator = coordinator
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewWillAppearEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.useCase.fetchPost()
                self.useCase.user
                    .compactMap { $0 }
                    .bind(to: output.user)
                    .disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
        
        input.commentRegisterButtonTapEvent
            .subscribe(onNext: { [weak self] comment in
                guard let self else { return }
                self.useCase.uploadComment(comment: comment)
                    .subscribe(onSuccess: {
                        output.commentWriteSuccess.accept(())
                    })
                    .disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
        
        input.postModifyButtonTapEvent
            .subscribe(onNext: { [weak self] post in
                guard let self else { return }
                self.coordinator?.showCommunityPostWriteViewController(post: post)
            }).disposed(by: disposeBag)
        
        input.postDeleteButtonTapEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.useCase.deletePost()
                self.coordinator?.popLastViewController()
            }).disposed(by: disposeBag)
        
        useCase.post
            .bind(to: output.post)
            .disposed(by: disposeBag)
        
        return output
    }
}
