//
//  DefaultRealtimeDatabaseNetworkService.swift
//  Acha
//
//  Created by 배남석 on 2022/11/23.
//

import Foundation
import Firebase
import RxSwift
import RxRelay

final class DefaultRealtimeDatabaseNetworkService: RealtimeDatabaseNetworkService {
    private let databaseReference: DatabaseReference = Database.database().reference()
    
    private func childReference(_ path: String) -> DatabaseReference {
        var childReference = self.databaseReference
        childReference = childReference.child(path)
        
        return childReference
    }
    
    func fetchData(path: String) -> Observable<Data> {
        let childReference = self.childReference(path)
        
        return Observable.create { observer in
            childReference.observeSingleEvent(of: .value, with: { snapshot in
                    guard let snapData = snapshot.value as? [Any],
                          let data = try? JSONSerialization.data(withJSONObject: snapData)
                    else {
                        observer.onError(FirebaseServiceError.nilDataError)
                        observer.onCompleted()
                        return
                    }
                    observer.onNext(data)
                    observer.onCompleted()
            })
            return Disposables.create()
        }
    }
}
