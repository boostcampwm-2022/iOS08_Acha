//
//  DefaultRealtimeDatabaseNetworkService.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/27.
//

import RxSwift
import Firebase

final class DefaultRealtimeDatabaseNetworkService: RealtimeDatabaseNetworkService {

    private let databaseReference: DatabaseReference = Database.database().reference()
    
    enum FirebaseRealtimeError: Error {
        case dataError
        case decodeError
        case encodeError
    }
    
    func fetch<T: Decodable>(type: FirebaseRealtimeType) -> Single<T> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            let childReference = self.databaseReference.child(type.path)
            childReference.observeSingleEvent(of: .value, with: { snapshot in
                guard let snapData = snapshot.value,
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
    
    func terminateGet(type: FirebaseRealtimeType, id: String) -> Observable<RoomDTO> {
        guard let uuid = try? KeyChainManager.get() else {return .empty()}
        guard let url = getURL(type: type) else {return .empty()}
        let urlRequest = URLRequest(url: url)
        return usingURL(request: urlRequest, type: RoomDTO.self)
            .map { var roomDTO = $0
                roomDTO.user = roomDTO.user.filter { $0.id != uuid }
                return roomDTO
            }
//            .map { self.terminatePost(type: .room(id: id), data: $0) }
    }
    
    func terminatePost<T: Codable>(type: FirebaseRealtimeType, data: T) -> Observable<T> {
        print("포스트포스트")
        guard let url = getURL(type: type) else {return .empty()}
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = ["Content-Type": "application/json"]
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = data.toJSON
        print(urlRequest)
        return usingURL(request: urlRequest, type: T.self)
    }
    
    private func getURL(type: FirebaseRealtimeType) -> URL? {
        let childReference = self.databaseReference.child(type.path).url + ".json"
        return URL(string: childReference)
    }
    
    private func usingURL<T: Codable>(
        request: URLRequest,
        type: T.Type
    ) -> Observable<T> {
        print("11111")
        return Observable<T>.create { observer in
            let task = URLSession.shared.dataTask(with: request) { data, resource, error in
                do {
                    guard let data = data else {return}
                    print(data)
                    guard let uuid = try? KeyChainManager.get() else {return}
                    guard var roomDTO = try JSONDecoder().decode(T.self, from: data) as? RoomDTO else {return}
                    print(roomDTO)
                    roomDTO.user = roomDTO.user.filter { $0.id != uuid }
                    self.upload(type: .room(id: roomDTO.id), data: roomDTO)
                } catch {
                    print(error)
                }
            }
            task.resume()
            
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
    
    func uploadPost(data: PostDTO) {
        let childReference = self.databaseReference.child(FirebaseRealtimeType.postList.path)
        guard let json = try? JSONEncoder().encode(data),
              let jsonSerial = try? JSONSerialization.jsonObject(with: json) as? [String: Any] ?? [:]
        else {
            print(FirebaseRealtimeError.encodeError)
            return
        }
        childReference.updateChildValues(["\(data.id)": jsonSerial])
    }
    
    func uploadComment(data: CommentDTO) {
        let childReference = self.databaseReference.child(FirebaseRealtimeType.comment(id: data.postId).path)
        guard let json = try? JSONEncoder().encode(data),
              let jsonSerial = try? JSONSerialization.jsonObject(with: json) as? [String: Any] ?? [:]
        else {
            print(FirebaseRealtimeError.encodeError)
            return
        }
        childReference.updateChildValues(["\(data.id)": jsonSerial])
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
