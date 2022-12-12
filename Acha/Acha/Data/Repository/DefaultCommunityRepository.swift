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
    
    func loadPost(count: Int = -1) -> Single<[Post]> {
        return Single.create { single in
            realtimeService.fetch(type: .postList,
                                  child: "id",
                                  value: count,
                                  limitCount: 5)
            .subscribe(onSuccess: { (postDTOs: [PostDTO?]) in
                single(.success(postDTOs.compactMap { $0 }.sorted(by: {
                    return $0.id < $1.id
                }).map { $0.toDomain() }))
            }, onFailure: { _ in
                single(.success([]))
            }).disposed(by: disposeBag)
            return Disposables.create()
        }
    }
    
    func getAllPost() -> Single<[Post]> {
        return Single.create { single in
            realtimeService.fetch(type: .postList)
                .subscribe(onSuccess: { (postDTOs: [PostDTO?]) in
                    single(.success(postDTOs.compactMap { $0 }.sorted(by: {
                        return $0.id < $1.id
                    }).map { $0.toDomain() }))
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
                        let minID = posts.max {
                            $0.id > $1.id
                        }?.id
                        
                        post.id = (minID ?? 1) - 1
                        
                        realtimeService.uploadPost(data: PostDTO(data: post))
                    })
                } else {
                    var post = post
                    let minID = posts.max {
                        $0.id > $1.id
                    }?.id
                    
                    post.id = (minID ?? 1) - 1
                    
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
                var newPost = post
                newPost.image = url.absoluteString
                
                realtimeService.uploadPost(data: PostDTO(data: newPost))
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
}
