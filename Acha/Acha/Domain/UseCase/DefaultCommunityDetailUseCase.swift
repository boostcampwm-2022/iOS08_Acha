//
//  DefaultCommunityDetailUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/12/05.
//

import Foundation
import RxSwift
import RxRelay

final class DefaultCommunityDetailUseCase: CommunityDetailUseCase {
    private let communityRepository: CommunityRepository
    private let userRepository: UserRepository
    private let postID: Int
    private let disposeBag = DisposeBag()
    var post = PublishSubject<(post: Post, isMine: Bool)>()
    var user = BehaviorSubject<User?>(value: nil)
    
    init(postID: Int,
         communityRepository: CommunityRepository,
         userRepository: UserRepository
    ) {
        self.postID = postID
        self.communityRepository = communityRepository
        self.userRepository = userRepository
        
        communityRepository.uploadCommentSuccess
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.fetchPost()
            })
            .disposed(by: disposeBag)
        
        userRepository.fetchUserData()
            .asObservable()
            .bind(to: user)
            .disposed(by: disposeBag)
    }
    
    func fetchPost() {
//        let postObservable = communityRepository.fetchPost(postID: postID)
//        let userObservable = user.asObservable()
//
//        Observable.combineLatest(postObservable, userObservable)
//            .map { (post: $0, isMine: ($0.userId == ($1?.id ?? "-1"))) }
//            .debug()
//            .bind(to: post)
//            .disposed(by: disposeBag)
        
        communityRepository.fetchPost(postID: postID)
            .subscribe(onNext: { [weak self] post in
                guard let self,
                      let user = try? self.user.value() else { return }
                
                self.post.onNext((post: post, isMine: post.userId == user.id))
            })
            .disposed(by: disposeBag)
    }
    
    func uploadComment(comment: Comment) -> Single<Void> {
        Single.create { [weak self] single in
            guard let self,
                  let user = try? self.user.value() else { return Disposables.create() }
            var comment = comment
            comment.postId = self.postID
            comment.nickName = user.nickName
            comment.userId = user.id
            self.communityRepository.uploadComment(comment: comment)
                .subscribe(onSuccess: {
                    single(.success(()))
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func deletePost() {
        communityRepository.deletePost(id: postID)
    }
}
