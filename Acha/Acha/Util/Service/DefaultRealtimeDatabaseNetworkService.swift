//
//  DefaultRealtimeDatabaseNetworkService.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/27.
//

import RxSwift
import Firebase
import FirebaseDatabase

final class DefaultRealtimeDatabaseNetworkService: RealtimeDatabaseNetworkService {
    private let databaseReference: DatabaseReference = Database.database().reference()
    
    enum FirebaseRealtimeError: Error {
        case dataError
        case decodeError
        case encodeError
    }
    
    func fetch<T: Decodable>(type: FirebaseRealtimeType,
                             child: String,
                             value: Any? = nil,
                             limitCount: Int? = nil) -> Single<T> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            var query = self.databaseReference.child(type.path).queryOrdered(byChild: child)
            
            if let value {
                query = query.queryStarting(afterValue: value)
            }
            
            if let limitCount {
                query = query.queryLimited(toFirst: UInt(limitCount))
            }
            
            query.observeSingleEvent(of: .value) { snapshot in
                guard var snapData = snapshot.value else {
                    single(.failure(FirebaseRealtimeError.dataError))
                    return
                }

                if snapData is [String: Any] {
                    guard let tempData = snapData as? [String: Any] else { return }
                    snapData = Array(tempData.values)
                }

                guard !(snapData is NSNull),
                      let jsonData = try? JSONSerialization.data(withJSONObject: snapData) else {
                    single(.failure(FirebaseRealtimeError.dataError))
                    return
                }

                guard let data = try? JSONDecoder().decode(T.self, from: jsonData) else {
                    single(.failure(FirebaseRealtimeError.decodeError))
                    return
                }
                single(.success(data))
            }
            return Disposables.create()
        }
    }
    
    func fetchAtKeyValue<T: Decodable>(type: FirebaseRealtimeType, value: Any, key: String) -> Single<T> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            let query = self.databaseReference.child(type.path).queryOrdered(byChild: key)
                .queryEqual(toValue: value)
            query.observeSingleEvent(of: .value, with: { snapshot in
                guard var snapData = snapshot.value else {
                    single(.failure(FirebaseRealtimeError.dataError))
                    return
                }

                if snapData is [String: Any] {
                    guard let tempData = snapData as? [String: Any] else { return }
                    snapData = Array(tempData.values)
                }

                guard !(snapData is NSNull),
                      let jsonData = try? JSONSerialization.data(withJSONObject: snapData) else {
                    single(.failure(FirebaseRealtimeError.dataError))
                    return
                }
                guard let data = try? JSONDecoder().decode(T.self, from: jsonData) else {
                    single(.failure(FirebaseRealtimeError.decodeError))
                    return
                }
                single(.success(data))
            })
            
            return Disposables.create()
        }
    }
    
    func fetch<T: Decodable>(type: FirebaseRealtimeType) -> Single<T> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            let childReference = self.databaseReference.child(type.path)
            childReference.observeSingleEvent(of: .value, with: { snapshot in
                guard let snapData = snapshot.value,
                      let jsonData = try? JSONSerialization.data(withJSONObject: snapData)else {
                    single(.failure(FirebaseRealtimeError.dataError))
                    return
                }
                guard let data = try? JSONDecoder().decode(T.self, from: jsonData) else {
                    single(.failure(FirebaseRealtimeError.decodeError))
                    return
                }
                single(.success(data))
            })
            return Disposables.create()
        }
    }
    
    func uploadNewRecord(index: Int, data: Record) {
        let childReference = self.databaseReference.child(FirebaseRealtimeType.record(id: nil).path)
        guard let json = try? JSONEncoder().encode(data),
              let jsonSerial = try? JSONSerialization.jsonObject(with: json) as? [String: Any] ?? [:]
        else {
            print(FirebaseRealtimeError.encodeError)
            return
        }
        childReference.updateChildValues(["\(index)": jsonSerial])
    }
    
    func uploadPost(data: PostDTO) -> Single<Void> {
        Single.create { single in
            let childReference = self.databaseReference.child(FirebaseRealtimeType.postList.path)
            guard let json = try? JSONEncoder().encode(data),
                  let jsonSerial = try? JSONSerialization.jsonObject(with: json) as? [String: Any] ?? [:]
            else {
                print(FirebaseRealtimeError.encodeError)
                return Disposables.create()
            }
            childReference.updateChildValues(["\(data.id)": jsonSerial]) { error, _ in
                if let error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    func uploadComment(data: CommentDTO) -> Single<Void> {
        Single.create { single in
            let childReference = self.databaseReference.child(FirebaseRealtimeType.comment(id: data.postId).path)
            guard let json = try? JSONEncoder().encode(data),
                  let jsonSerial = try? JSONSerialization.jsonObject(with: json) as? [String: Any] ?? [:]
            else {
                print(FirebaseRealtimeError.encodeError)
                return Disposables.create()
            }
            childReference.updateChildValues(["\(data.id)": jsonSerial]) { error, _ in
                if let error {
                    single(.failure(error))
                } else {
                    single(.success(()))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func upload<T: Encodable>(type: FirebaseRealtimeType, data: T) {
        let childReference = self.databaseReference.child(type.path)
        guard let json = try? JSONEncoder().encode(data),
              let jsonSerial = try? JSONSerialization.jsonObject(with: json) as? [String: Any] ?? [:]
        else {
            print(FirebaseRealtimeError.encodeError)
            return
        }
        childReference.setValue(jsonSerial)
    }
    
    func delete(type: FirebaseRealtimeType) {
        let childReference = self.databaseReference.child(type.path)
        childReference.removeValue()
    }
    
    func observing<T: Decodable>(type: FirebaseRealtimeType) -> Observable<T> {
        return Observable<T>.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            let childReference = self.databaseReference.child(type.path)
            childReference.observe(.value) { snapshot in
                guard let snapData = snapshot.value,
                      let jsonData = try? JSONSerialization.data(withJSONObject: snapData) else {
                    observer.onError(FirebaseRealtimeError.dataError)
                    return
                }
                guard let data = try? JSONDecoder().decode(T.self, from: jsonData) else {
                    observer.onError(FirebaseRealtimeError.decodeError)
                    return
                }
                observer.onNext(data)
            }
            return Disposables.create()
        }
    }
    
    func removeObserver(type: FirebaseRealtimeType) {
        let childReference = self.databaseReference.child(type.path)
        childReference.removeAllObservers()
    }
}
