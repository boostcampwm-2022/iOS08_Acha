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
        repository.getAllPost()
            .subscribe(onSuccess: { posts in
                guard let post = posts.first(where: { $0.id == self.postID }) else { return }
                self.post.onNext(post)
            })
            .disposed(by: disposeBag)
    }
    
    func uploadComment(comment: Comment) {
        var comment = comment
        comment.postId = postID
        repository.uploadComment(comment: comment)
    }
}
