//
//  RealtimeDatabaseNetworkService.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/27.
//

import RxSwift

protocol RealtimeDatabaseNetworkService {
    func fetch<T: Decodable>(type: FirebaseRealtimeType,
                             child: String,
                             value: Any?,
                             limitCount: Int?) -> Single<T>
    func fetch<T: Decodable>(type: FirebaseRealtimeType) -> Single<T>
    func fetchAtKeyValue<T: Decodable>(type: FirebaseRealtimeType, value: Any, key: String) -> Single<T>
    func uploadNewRecord(index: Int, data: Record)
    func uploadPost(data: PostDTO) -> Single<Void>
    func uploadComment(data: CommentDTO) -> Single<Void>
    func upload<T: Encodable>(type: FirebaseRealtimeType, data: T)
    func delete(type: FirebaseRealtimeType) -> Single<Void>
    func observing<T: Decodable>(type: FirebaseRealtimeType) -> Observable<T>
    func removeObserver(type: FirebaseRealtimeType)
}
