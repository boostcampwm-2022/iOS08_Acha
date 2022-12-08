//
//  DefaultCommunityRepository.swift
//  Acha
//
//  Created by hong on 2022/12/01.
//

import Foundation
import RxSwift

struct DefaultCommunityRepository: CommunityRepository {
    private let realtimeService: RealtimeDatabaseNetworkService
    private let storageService: FirebaseStorageNetworkService?
    private let disposeBag = DisposeBag()
    
    var uploadCommentSuccess = PublishSubject<Bool>()
    
    init(
        realtimeService: RealtimeDatabaseNetworkService,
        storageService: FirebaseStorageNetworkService? = nil
    ) {
        self.realtimeService = realtimeService
        
        if let storageService {
            self.storageService = storageService
        } else {
            self.storageService = nil
        }
    }
    
    func getAllPost() -> Single<[Post]> {
        return Single.create { single in
            realtimeService.fetch(type: .postList)
                .subscribe(onSuccess: { (postDTOs: [PostDTO?]) in
                    single(.success(postDTOs.compactMap { $0 }.map { $0!.toDomain() }))
                }, onFailure: { _ in
                    single(.success([]))
                }).disposed(by: disposeBag)
            
            return Disposables.create()
        }
    }
    
    func getImage(urlString: String) -> Single<Image> {
        return Single.create { single in
            storageService?.download(urlString: urlString, completion: { data in
                if let data {
                    single(.success(Image(name: urlString, data: data)))
                }
            })
            
            return Disposables.create()
        }
    }
    
    func uploadPost(post: Post, image: Image?) {
            Single.create { single in
                realtimeService.fetch(type: .postList)
                    .subscribe(onSuccess: { (postDTOs: [PostDTO?]) in
                        single(.success(postDTOs.compactMap { $0 }.map { $0.toDomain() }))
                    }, onFailure: { _ in
                        single(.success([]))
                    }).disposed(by: disposeBag)
                
                return Disposables.create()
            }
            .subscribe(onSuccess: { posts in
                if let image {
                    storageService?.upload(type: .category(image.name),
                                           data: image.data,
                                           completion: { url in
                        guard let url else { return }
                        var post = post
                        post.image = url.absoluteString
                        let maxID = posts.max {
                            $0.id < $1.id
                        }?.id
                        
                        post.id = (maxID ?? -1) + 1
                        
                        realtimeService.uploadPost(data: PostDTO(data: post))
                    })
                } else {
                    var post = post
                    let maxID = posts.max {
                        $0.id < $1.id
                    }?.id
                    
                    post.id = (maxID ?? -1) + 1
                    
                    realtimeService.uploadPost(data: PostDTO(data: post))
                }
            }).disposed(by: disposeBag)
    }
    
    func updatePost(post: Post, image: Image?) {
        if let image {
            storageService?.upload(type: .category(image.name),
                                   data: image.data,
                                   completion: { url in
                guard let url else { return }
                var post = post
                post.image = url.absoluteString
                
                realtimeService.uploadPost(data: PostDTO(data: post))
            })
        } else {
            realtimeService.uploadPost(data: PostDTO(data: post))
        }
    }
    
    func deletePost(id: Int) {
        realtimeService.delete(type: .post(id: id))
    }
    
    func uploadComment(comment: Comment) {
        Single.create { single in
            realtimeService.fetch(type: .post(id: comment.postId))
                .subscribe(onSuccess: { (postDTO: PostDTO) in
                    let post = postDTO.toDomain()
                    guard let comments = post.comments else { return }
                    single(.success(comments))
                }, onFailure: { _ in
                    single(.success([Comment]()))
                }).disposed(by: disposeBag)
            
            return Disposables.create()
        }
        .subscribe(onSuccess: { comments in
            var comment = comment
            let maxID = comments.max {
                $0.id < $1.id
            }?.id
            
            comment.id = (maxID ?? -1) + 1
            
            realtimeService.uploadComment(data: CommentDTO(data: comment))
            
            uploadCommentSuccess.onNext(true)
        })
        .disposed(by: disposeBag)
    }
    
//    func getAllPost() -> Single<[Post]> {
//        return getCommunity()
//            .map { $0.map { $0.toDomain() } }
//    }
    
//    func getPostComments(id: Int) -> Single<[Comment]> {
//        return getPost(id: id)
//            .map { $0?.comments ?? [] }
//    }
//
//    func getPostComment(id: Int) -> Single<Comment?> {
//        return getPostComments(id: id)
//            .map { return $0.first { $0.id == id } }
//    }
    
//    func makePost(data: Post) {
//        let data = PostDTO(data: data)
//
//        getCommunity()
//            .map {
//                var community = CommunityDTO(postList: $0)
//                community.addPost(post: data)
//                service.upload(type: .postList, data: community)
//            }
//            .subscribe()
//            .disposed(by: disposeBag)
//    }
//
//    func makeComment(data: Comment) {
//        getPost(id: data.postId)
//            .map {
//                guard var post = $0 else { return }
//                post.addComment(data: data)
//                changePost(data: post)
//            }
//            .subscribe()
//            .disposed(by: disposeBag)
//    }
//

//
//    func deleteComment(data: Comment) {
//        getPost(id: data.postId)
//            .map {
//                guard var post = $0 else { return }
//                post.comments = post.comments?.filter { $0.id != data.id }
//                changePost(data: post)
//            }
//            .subscribe()
//            .disposed(by: disposeBag)
//    }
//
//    func changePost(data: Post) {
//        getCommunity()
//            .subscribe { result in
//                switch result {
//                case .success(var posts):
//                    let index = posts.firstIndex { $0.id == data.id }
//                    guard let postIndex = index else {return}
//                    let newPost = PostDTO(data: data)
//                    posts[postIndex] = newPost
//                    updateCommunity(data: posts)
//                default:
//                    break
//                }
//            }
//            .disposed(by: disposeBag)
//    }
//
//    func changeComment(data: Comment) {
//        getPost(id: data.postId)
//            .map {
//                guard var post = $0 else { return }
//                var comments = post.comments ?? []
//                let index = comments.firstIndex { $0.id == data.id }
//                guard let commentIndex = index else {return}
//                comments[commentIndex] = data
//                post.comments = comments
//                changePost(data: post)
//            }
//            .subscribe()
//            .disposed(by: disposeBag)
//    }
//
//    private func updateCommunity(data: [PostDTO]) {
//        let community = CommunityDTO(postList: data)
//        service.upload(type: .postList, data: community)
//    }
//
}
