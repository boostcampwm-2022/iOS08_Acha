//
//  CommunityMainUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/11/30.
//

import Foundation
import RxSwift

protocol CommunityMainUseCase {
    var posts: PublishSubject<[Post]> { get set }
    func loadPostData()
}
