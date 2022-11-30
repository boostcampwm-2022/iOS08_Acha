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
    
    func fetch<T: Decodable>(path: FirebasePath) -> Single<T> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            let childReference = self.databaseReference.child(path.rawValue)
            childReference.observeSingleEvent(of: .value, with: { snapshot in
                guard let snapData = snapshot.value,
                      let jsonData = try? JSONSerialization.data(withJSONObject: snapData) else {
                    single(.failure(NetworkError.dataError))
                    return
                }
                guard let data = try? JSONDecoder().decode(T.self, from: jsonData) else {
                    single(.failure(NetworkError.decodeError))
                    return
                }
                single(.success(data))
            })
            return Disposables.create()
        }
    }
    
    func fetch<T: Decodable>(path: FirebasePath) -> Single<T> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            let childReference = self.childReference(path: path.rawValue)
            childReference.observeSingleEvent(of: .value, with: { snapshot in
                guard let snapData = snapshot.value as? [Any],
                      let jsonData = try? JSONSerialization.data(withJSONObject: snapData) else {
                    single(.failure(NetworkError.dataError))
                    return
                }
                guard let data = try? JSONDecoder().decode(T.self, from: jsonData) else {
                    single(.failure(NetworkError.decodeError))
                    return
                }
                single(.success(data))
            })
            return Disposables.create()
        }
    }
}
