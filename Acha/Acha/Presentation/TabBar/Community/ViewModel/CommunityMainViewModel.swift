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
    }
    
    // MARK: - Output
    struct Output {
        var posts = PublishRelay<[Post]>()
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
                self.useCase.loadPostData()
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
        
        useCase.posts
            .bind(to: output.posts)
            .disposed(by: disposeBag)
        
        return output
    }
   
}
