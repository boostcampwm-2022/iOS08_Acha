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
    private let repository: CommunityRepository
    private let postID: Int
    private let disposeBag = DisposeBag()
    var post = PublishSubject<Post>()
    
    init(postID: Int, repository: CommunityRepository) {
        self.postID = postID
        self.repository = repository
        
        repository.uploadCommentSuccess
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
    }
    
    func uploadComment(comment: Comment) -> Single<Void> {
        Single.create { [weak self] single in
            guard let self else { return Disposables.create()}
            
            var comment = comment
            comment.postId = self.postID
            self.repository.uploadComment(comment: comment)
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
            
            self.repository.deletePost(id: self.postID)
                .subscribe(onSuccess: { _ in
                    single(.success(()))
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}
