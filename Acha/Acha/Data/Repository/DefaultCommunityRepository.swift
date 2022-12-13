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
    private let imageCacheService: ImageCacheService
    private let disposeBag = DisposeBag()
    
    var uploadCommentSuccess = PublishSubject<Bool>()
    
    init(
        realtimeService: RealtimeDatabaseNetworkService,
        storageService: FirebaseStorageNetworkService? = nil,
        imageCacheService: ImageCacheService
    ) {
        self.realtimeService = realtimeService
        
        if let storageService {
            self.storageService = storageService
        } else {
            self.storageService = nil
        }
        self.imageCacheService = imageCacheService
    }
    
    func loadPost(count: Int = -1) -> Observable<[Post]> {
        realtimeService.fetch(type: .postList,
                              child: "id",
                              value: count,
                              limitCount: 5)
        .asObservable()
        .flatMap { (postDTOs: [PostDTO?]) in
            let postDTOs = postDTOs.compactMap { $0 }.sorted(by: { return $0.id < $1.id })
            return Observable.zip(postDTOs.map { postDTO in
                guard let imageURL = postDTO.image,
                      let storageService else {
                    return Observable.of(postDTO.toDomain())
                }
                if self.imageCacheService.isExist(imageURL: imageURL) {
                    return self.imageCacheService.load(imageURL: imageURL)
                        .asObservable()
                        .map { data in
                            var post = postDTO.toDomain()
                            post.image = data
                            return post
                        }
                }
                
                return storageService.download(urlString: imageURL)
                    .map { data -> Post in
                        self.imageCacheService.write(imageURL: imageURL, image: data)
                        var post = postDTO.toDomain()
                        post.image = data
                        return post
                    }
            })
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
    
    func uploadPost(post: Post, image: Image?) -> Single<Void> {
        Single.create { single in
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
                        let minID = posts.max {
                            $0.id > $1.id
                        }?.id
                        post.id = (minID ?? 1) - 1
                        
                        let postDTO = PostDTO(data: post,
                                              image: url.absoluteString)
                        realtimeService.uploadPost(data: postDTO)
                            .subscribe(onSuccess: {
                                single(.success(()))
                            }, onFailure: { error in
                                single(.failure(error))
                            })
                            .disposed(by: disposeBag)
                    })
                } else {
                    var post = post
                    let minID = posts.max {
                        $0.id > $1.id
                    }?.id
                    post.id = (minID ?? 1) - 1
                    realtimeService.uploadPost(data: PostDTO(data: post))
                        .subscribe(onSuccess: {
                            single(.success(()))
                        }, onFailure: { error in
                            single(.failure(error))
                        })
                        .disposed(by: disposeBag)
                }
            }).disposed(by: disposeBag)
            return Disposables.create()
        }
    }
    
    func updatePost(post: Post, image: Image?) -> Single<Void> {
        Single.create { single in
            if let image {
                storageService?.upload(type: .category(image.name),
                                       data: image.data,
                                       completion: { url in
                    guard let url else { return }
                    let postDTO = PostDTO(data: post,
                                          image: url.absoluteString)
                    
                    realtimeService.uploadPost(data: postDTO)
                        .subscribe(onSuccess: {
                            single(.success(()))
                        }, onFailure: { error in
                            single(.failure(error))
                        })
                        .disposed(by: disposeBag)
                })
            } else {
                realtimeService.uploadPost(data: PostDTO(data: post))
                    .subscribe(onSuccess: {
                        single(.success(()))
                    }, onFailure: { error in
                        single(.failure(error))
                    })
                    .disposed(by: disposeBag)
            }
            return Disposables.create()
        }
    }
    
    func deletePost(id: Int) {
        realtimeService.delete(type: .post(id: id))
    }
    
    func uploadComment(comment: Comment) -> Single<Void> {
        Single.create { single in
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
                    .subscribe(onSuccess: {
                        single(.success(()))
                    }, onFailure: { error in
                        single(.failure(error))
                    })
                    .disposed(by: disposeBag)
                
                uploadCommentSuccess.onNext(true)
            })
            .disposed(by: disposeBag)
            
            return Disposables.create()
        }
    }
}
