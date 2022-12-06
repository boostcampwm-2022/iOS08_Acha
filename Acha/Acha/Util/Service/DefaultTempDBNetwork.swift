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
import FirebaseDatabase

final class DefaultTempDBNetwork: TempDBNetwork {
    var databaseReference = Database.database().reference()
    
    private func childReference(_ path: String) -> DatabaseReference {
        return databaseReference.child(path)
    }
    
    func fetchData(path: String) -> Observable<Data> {
        let childReference = self.childReference(path)
        
        return Observable.create { observer in
            childReference.observeSingleEvent(of: .value, with: { snapshot in
                    guard let snapData = snapshot.value as? [Any],
                          let data = try? JSONSerialization.data(withJSONObject: snapData)
                    else {
                        observer.onError( fatalError() )
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
