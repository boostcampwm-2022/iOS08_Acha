//
//  DefaultCommunityPostWriteUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/12/06.
//

import Foundation
import RxSwift
import RxRelay

final class DefaultCommunityPostWriteUseCase: CommunityPostWriteUseCase {
    private let communityRepository: CommunityRepository
    private let userRepository: UserRepository
    private let disposeBag = DisposeBag()
    let post: Post!
    
    init(post: Post? = nil,
         communityRepository: CommunityRepository,
         userRepository: UserRepository
    ) {
        self.communityRepository = communityRepository
        self.post = post
        self.userRepository = userRepository
    }
    
    func confirmHavePost() -> Single<Post?> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create()}
            if let post = self.post {
                single(.success(post))
            }
            return Disposables.create()
        }
    }
    
    func uploadPost(postContent: String, image: Image?) -> Single<Void> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create()}
            self.userRepository.fetchUserData()
                .subscribe(onSuccess: { user in
                    if let selfPost = self.post {
                        var uploadPost = selfPost
                        uploadPost.text = postContent
                        uploadPost.userId = user.id
                        uploadPost.nickName = user.nickName
                        self.communityRepository.updatePost(post: uploadPost, image: image)
                            .subscribe(onSuccess: {
                                single(.success(()))
                            })
                            .disposed(by: self.disposeBag)
                    } else {
                        var post = Post(userId: user.id, nickName: user.nickName, text: postContent)
                        self.communityRepository.uploadPost(post: post, image: image)
                            .subscribe(onSuccess: {
                                single(.success(()))
                            })
                            .disposed(by: self.disposeBag)
                    }
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
}
