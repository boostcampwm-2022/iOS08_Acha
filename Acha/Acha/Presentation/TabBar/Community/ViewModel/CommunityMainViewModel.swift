//
//  CommunityMainViewModel.swift
//  Acha
//
//  Created by 배남석 on 2022/11/30.
//

import Foundation
import RxSwift
import RxRelay

final class CommunityMainViewModel: BaseViewModel {
    // MARK: - Input
    struct Input {
        var viewDidAppearEvent: Observable<Void>
        var cellTapEvent: Observable<Int>
        var rightButtonTapEvent: Observable<Void>
        var cellReloadEvent: Observable<Int>
    }
    
    // MARK: - Output
    struct Output {
        var posts = PublishRelay<[Post]>()
        var reloadEvent = PublishRelay<Void>()
    }
    
    // MARK: - Dependency
    var disposeBag = DisposeBag()
    private let useCase: CommunityMainUseCase
    private weak var coordinator: CommunityCoordinator?
    
    // MARK: - Lifecycles
    init(useCase: CommunityMainUseCase,
         coordinator: CommunityCoordinator) {
        self.useCase = useCase
        self.coordinator = coordinator
    }
    
    // MARK: - Helpers
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewDidAppearEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.useCase.loadPostData(count: Int.min)
            }).disposed(by: disposeBag)
        
        input.cellTapEvent
            .subscribe(onNext: { [weak self] postID in
                guard let self else { return }
                self.coordinator?.showCommunityDetailViewController(postID: postID)
            }).disposed(by: disposeBag)
        
        input.rightButtonTapEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.coordinator?.showCommunityPostWriteViewController()
            }).disposed(by: disposeBag)
        
        input.cellReloadEvent
            .subscribe(onNext: { [weak self] postCount in
                guard let self else { return }
                self.useCase.loadPostData(count: postCount)
            }).disposed(by: disposeBag)
        
        useCase.posts
            .subscribe(onNext: { posts in
                if posts.isEmpty {
                    output.reloadEvent.accept(())
                } else {
                    output.posts.accept(posts)
                }
            }).disposed(by: disposeBag)
        
        return output
    }
   
}
