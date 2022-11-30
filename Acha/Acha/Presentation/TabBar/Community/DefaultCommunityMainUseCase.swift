//
//  CommunityMainUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/11/30.
//

import Foundation
import RxSwift
import RxRelay

final class DefaultCommunityMainUseCase: CommunityMainUseCase {
    var repository: CommunityRepository
    
    init(repository: CommunityRepository) {
        self.repository = repository
    }
    
    
}
