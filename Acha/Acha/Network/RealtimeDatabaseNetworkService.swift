//
//  RealtimeDatabaseNetworkService.swift
//  Acha
//
//  Created by 배남석 on 2022/11/23.
//

import Foundation
import RxRelay
import RxSwift

protocol RealtimeDatabaseNetworkService {
    func fetchData(path: String) -> Observable<Data>
}
