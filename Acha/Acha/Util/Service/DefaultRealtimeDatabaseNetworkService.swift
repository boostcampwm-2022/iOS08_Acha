//
//  DefaultRealtimeDatabaseNetworkService.swift
//  Acha
//
//  Created by 조승기 on 2022/11/27.
//

import Foundation
import Firebase
import RxSwift

final class DefaultRealtimeDatabaseNetworkService: RealtimeDatabaseNetworkService {
    private let databaseReference: DatabaseReference = Database.database().reference()
    
    private func childReference(path: String) -> DatabaseReference {
        return databaseReference.child(path)
    }
    
    func fetch<T: Decodable>(path: String) -> Single<T> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            let childReference = self.childReference(path: path)
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

