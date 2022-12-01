//
//  DefaultCommunityRepository.swift
//  Acha
//
//  Created by hong on 2022/12/01.
//

import Foundation
import RxSwift

struct DefaultCommunityRepository {
    private let service: RealtimeDatabaseNetworkService
    
    init(service: RealtimeDatabaseNetworkService) {
        self.service = service
    }
    
    func getAllPost() -> Single<[Post]> {
        return service.fetch(type: .postList)
            .map { (postDTOs: [PostDTO]) in
                postDTOs.map { $0.toDomain() }
            }
    }
    
    func getPost(id: Int) -> Single<Post> {
        return service.fetch(type: .post(id: id))
            .map { (postDTO: PostDTO) in
                return postDTO.toDomain()
            }
    }
    
//    func makePost(data: Post) {
//        let data = PostDTO(
//            id: data.id,
//            userId: data.userId,
//            nickName: data.nickName,
//            text: data.text,
//            image: data.image
//        )
//        service.upload(type: .post(id: data.id), data: data)
//    }
}
