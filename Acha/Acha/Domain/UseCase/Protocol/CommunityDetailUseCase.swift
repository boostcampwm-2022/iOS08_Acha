//
//  CommunityDetailUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/12/05.
//

import Foundation
import RxSwift

protocol CommunityDetailUseCase {
    func fetchPost()
    func uploadComment(comment: Comment) -> Single<Void>
    func deletePost()
    
    var post: PublishSubject<(post: Post, isMine: Bool)> { get set }
    var user: BehaviorSubject<User?> { get set }
}
