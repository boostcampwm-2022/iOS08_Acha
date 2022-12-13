//
//  CommunityPostWriteUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/12/06.
//

import Foundation
import RxSwift
import RxRelay

protocol CommunityPostWriteUseCase {
    func confirmHavePost() -> Single<Post?>
    func uploadPost(post: Post, image: Image?) -> Single<Void>
}
