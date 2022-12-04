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

}
