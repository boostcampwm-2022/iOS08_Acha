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
    var post = PublishSubject<Post>()
    
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
    }
    
    func fetchPost() {
        repository.fetchPost(postID: postID)
            .subscribe(onNext: { [weak self] post in
                guard let self else { return }
                self.post.onNext(post)
            })
            .disposed(by: disposeBag)
//        repository.getAllPost()
//            .subscribe(onSuccess: { posts in
//                guard let post = posts.first(where: { $0.id == self.postID }) else { return }
//                self.post.onNext(post)
//            })
//            .disposed(by: disposeBag)
    }
    
    func uploadComment(comment: Comment) -> Single<Void> {
        Single.create { [weak self] single in
            guard let self else { return Disposables.create()}
            
            self.userRepository.fetchUserData()
                .subscribe(onSuccess: { user in
                    var comment = comment
                    comment.postId = self.postID
                    comment.nickName = user.nickName
                    comment.userId = user.id
                    self.communityRepository.uploadComment(comment: comment)
                        .subscribe(onSuccess: {
                            single(.success(()))
                        })
                        .disposed(by: self.disposeBag)
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func deletePost() {
        communityRepository.deletePost(id: postID)
    }
}
