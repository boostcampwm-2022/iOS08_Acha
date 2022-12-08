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
    
    init(repository: CommunityRepository) {
        self.repository = repository
    }
    
    func uploadPost(post: Post, image: Image?) {
        repository.uploadPost(post: post, image: image)
    }
}
