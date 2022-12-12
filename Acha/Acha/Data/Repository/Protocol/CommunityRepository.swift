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
    
    func loadPost(count: Int) -> Single<[Post]>
    func getAllPost() -> Single<[Post]>
    func getImage(urlString: String) -> Single<Image>
    func uploadPost(post: Post, image: Image?)
    func updatePost(post: Post, image: Image?)
    func deletePost(id: Int)
    func uploadComment(comment: Comment)
}
