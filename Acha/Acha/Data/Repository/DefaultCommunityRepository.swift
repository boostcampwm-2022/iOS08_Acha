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
            .map { return $0.first { $0.id == id }! }
    }
    
    func getPostComments(id: Int) -> Single<[Comment]> {
        return getPost(id: id)
            .map { $0.comments ?? [] }
    }
    
    func getPostComment(id: Int) -> Single<Comment?> {
        return getPostComments(id: id)
            .map { return $0.first { $0.id == id }! }
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
                changePost(data: post)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func deletePost(id: Int) {
        getCommunity()
            .map { $0.filter { $0.id != id } }
            .map {
                updateCommunity(data: $0)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func deleteComment(data: Comment) {
        getPost(id: data.postId)
            .map {
                var post = $0
                post.comments = post.comments?.filter { $0.id != data.id }
                changePost(data: post)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func changePost(data: Post) {
        getCommunity()
            .subscribe { result in
                switch result {
                case .success(var posts):
                    let index = posts.firstIndex { $0.id == data.id }!
                    let newPost = PostDTO(data: data)
                    posts[index] = newPost
                    updateCommunity(data: posts)
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
    
    func changeComment(data: Comment) {
        getPost(id: data.postId)
            .map {
                var post = $0
                var comments = post.comments ?? []
                let index = comments.firstIndex { $0.id == data.id }!
                comments[index] = data
                post.comments = comments
                changePost(data: post)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func updateCommunity(data: [PostDTO]) {
        let community = CommunityDTO(postList: data)
        service.upload(type: .postList, data: community)
    }
    
}
