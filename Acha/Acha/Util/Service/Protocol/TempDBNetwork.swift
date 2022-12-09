//
//  RealtimeDatabaseNetworkService.swift
//  Acha
//
//  Created by 배남석 on 2022/11/23.
//

import Foundation
import RxRelay
import RxSwift
import Firebase

protocol TempDBNetwork {
    var databaseReference: DatabaseReference { get set }
    func fetchData(path: String) -> Observable<Data>
}
