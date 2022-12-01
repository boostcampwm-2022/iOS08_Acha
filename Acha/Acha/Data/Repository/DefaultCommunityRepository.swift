//
//  DefaultCommunityRepository.swift
//  Acha
//
//  Created by hong on 2022/12/01.
//

import Foundation
import RxSwift

struct DefaultCommunityRepository: CommunityRepository {
    
    private let service: RealtimeDatabaseNetworkService
    private let userRepository: UserRepository
    
    init(
        service: RealtimeDatabaseNetworkService,
        userRepository: UserRepository
    ) {
        self.service = service
    }
    
    func getAllPost() -> Single<[Post]> {
        return service.fetch(type: .postList)
            .map { (postDTOS: [PostDTO]) in
                postDTOS.map { $0.toDomain() }
            }
    }
    
    func getPost(id: Int) -> Single<Post> {
        return service.fetch(type: .post(id: id))
            .map { (postDTO: PostDTO) in
                return postDTO.toDomain()
            }
    }

}
