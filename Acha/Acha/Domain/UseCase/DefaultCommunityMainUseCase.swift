//
//  CommunityMainUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/11/30.
//

import Foundation
import RxSwift
import RxRelay

final class DefaultCommunityMainUseCase: CommunityMainUseCase {
    var repository: DefaultCommunityRepository
    var disposeBag = DisposeBag()
    
    var posts = BehaviorSubject<[Post]>(value: [])
    
    init(repository: DefaultCommunityRepository) {
        self.repository = repository
    }
    
    func loadPostData() {
        repository.getAllPost()
            .subscribe(onSuccess: { [weak self] posts in
                guard let self else { return }
                self.posts.onNext(posts)
            })
            .disposed(by: disposeBag)
    }
}
