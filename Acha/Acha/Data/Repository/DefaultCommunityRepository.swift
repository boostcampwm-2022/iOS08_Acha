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
    private let disposeBag = DisposeBag()
    
    init(
        service: RealtimeDatabaseNetworkService
    ) {
        self.service = service
    }
    
    private func getCommunity() -> Single<[PostDTO]> {
        return service.fetch(type: .postList)
            .map { (communityDTO: CommunityDTO) in
                return communityDTO.postList ?? []
            }
    }
    
    func getAllPost() -> Single<[Post]> {
        return getCommunity()
            .map { $0.map { $0.toDomain() } }
    }
    
    func getPost(id: Int) -> Single<Post> {
        return getAllPost()
            .map { $0.filter { $0.id == id } }
            .map { $0[0] }
    }
    
    func getPostComments(id: Int) -> Single<[Comment]> {
        return getPost(id: id)
            .map { $0.comments ?? [] }
    }
    
    func makePost(data: Post) {
        let data = PostDTO(data: data)
        
        getCommunity()
            .map {
                var community = CommunityDTO(postList: $0)
                community.addPost(post: data)
                service.upload(type: .postList, data: community)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func makeComment(data: Comment) {
        getPost(id: data.postId)
            .map {
                var post = $0
                post.addComment(data: data)
                makePost(data: post)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func deletePost(id: Int) {
        getCommunity()
            .map { $0.filter { $0.id != id } }
            .map {
                let community = CommunityDTO(postList: $0)
                service.upload(type: .postList, data: community)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}
