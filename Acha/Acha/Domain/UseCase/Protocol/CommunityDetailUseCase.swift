//
//  CommunityDetailUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/12/05.
//

import Foundation
import RxSwift

protocol CommunityDetailUseCase {
    var post: PublishSubject<Post> { get set }
    
    func fetchPost()
    func uploadComment(comment: Comment)
}
