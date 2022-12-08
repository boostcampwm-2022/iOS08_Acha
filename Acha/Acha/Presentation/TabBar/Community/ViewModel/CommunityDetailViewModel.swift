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
        var postModifyButtonTapEvent: Observable<Void>
        var postDeleteButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        var post = PublishRelay<Post>()
    }
    
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    private let useCase: CommunityDetailUseCase
    
    // MARK: - Lifecycles
    init(useCase: CommunityDetailUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewWillAppearEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.useCase.fetchPost()
            }).disposed(by: disposeBag)
        
        input.commentRegisterButtonTapEvent
            .subscribe(onNext: { [weak self] comment in
                guard let self else { return }
                self.useCase.uploadComment(comment: comment)
            }).disposed(by: disposeBag)
        
        input.postModifyButtonTapEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                print("modify")
            }).disposed(by: disposeBag)
        
        input.postDeleteButtonTapEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                print("delete")
            }).disposed(by: disposeBag)
        
        useCase.post
            .bind(to: output.post)
            .disposed(by: disposeBag)
        
        return output
    }
}
