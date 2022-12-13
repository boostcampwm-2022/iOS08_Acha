//
//  FirebaseStorageNetworkService.swift
//  Acha
//
//  Created by 배남석 on 2022/12/07.
//

import Foundation
import RxSwift

protocol FirebaseStorageNetworkService {
    func upload(type: FirebaseStorageType, data: Data, completion: @escaping (URL?) -> Void)
    func download(urlString: String, completion: @escaping (Data?) -> Void)
    func download(urlString: String) -> Observable<Data>
}
