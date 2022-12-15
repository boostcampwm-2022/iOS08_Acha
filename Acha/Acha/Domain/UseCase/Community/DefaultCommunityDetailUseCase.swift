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
    var fetchFailure = PublishSubject<Void>()
    
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
        communityRepository.fetchPost(postID: postID)
            .subscribe(onNext: { [weak self] post in
                guard let self,
                      let user = try? self.user.value() else { return }
                
                self.post.onNext((post: post, isMine: post.userId == user.id))
            }, onError: { [weak self] _ in
                guard let self else { return }
                self.fetchFailure.onNext(())
            })
            .disposed(by: disposeBag)
    }
    
    func uploadComment(commentMessage: String) -> Single<Void> {
        Single.create { [weak self] single in
            guard let self,
                  let user = try? self.user.value() else { return Disposables.create() }
            let comment = Comment(postId: self.postID,
                                  userId: user.id,
                                  nickName: user.nickName,
                                  text: commentMessage)
            self.communityRepository.uploadComment(comment: comment)
                .subscribe(onSuccess: {
                    single(.success(()))
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func deletePost() -> Single<Void> {
        Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            
            self.communityRepository.deletePost(id: self.postID)
                .subscribe(onSuccess: { _ in
                    single(.success(()))
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}
