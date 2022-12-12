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
    private let repository: CommunityRepository
    private let disposeBag = DisposeBag()
    let post: Post!
    
    init(repository: CommunityRepository, post: Post? = nil) {
        self.repository = repository
        self.post = post
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
    
    func uploadPost(post: Post, image: Image?) -> Single<Void> {
        Single.create { [weak self] single in
            guard let self else { return Disposables.create()}
            
            if let selfPost = self.post {
                var uploadPost = selfPost
                uploadPost.text = post.text
                self.repository.updatePost(post: uploadPost, image: image)
                    .subscribe(onSuccess: {
                        single(.success(()))
                    })
                    .disposed(by: self.disposeBag)
            } else {
                self.repository.uploadPost(post: post, image: image)
                    .subscribe(onSuccess: {
                        single(.success(()))
                    })
                    .disposed(by: self.disposeBag)
            }
            return Disposables.create()
        }
    }
}
