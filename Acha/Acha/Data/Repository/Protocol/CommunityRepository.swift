//
//  CommunityRepository.swift
//  Acha
//
//  Created by 배남석 on 2022/12/05.
//

import Foundation
import RxSwift

protocol CommunityRepository {
    var uploadCommentSuccess: PublishSubject<Bool> { get set }
    
    func loadPost(count: Int) -> Observable<[Post]>
    func fetchPost(postID: Int) -> Observable<Post>
    func uploadPost(post: Post, image: Image?) -> Single<Void>
    func updatePost(post: Post, image: Image?) -> Single<Void> 
    func deletePost(id: Int) -> Single<Void>
    func uploadComment(comment: Comment) -> Single<Void>
}
