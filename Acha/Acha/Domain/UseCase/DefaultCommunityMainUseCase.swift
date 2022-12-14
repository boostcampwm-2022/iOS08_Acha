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
    private let communityRepository: DefaultCommunityRepository
    private let disposeBag = DisposeBag()
    
    var posts = PublishSubject<[Post]>()
    
    init(communityRepository: DefaultCommunityRepository) {
        self.communityRepository = communityRepository
    }
    
    func loadPostData(count: Int) {
        communityRepository.loadPost(count: count)
            .subscribe(onNext: { [weak self] posts in
                guard let self else { return }
                self.posts.onNext(posts)
            }, onError: { [weak self] _ in
                guard let self else { return }
                self.posts.onNext([])
            })
            .disposed(by: disposeBag)
    }
}
