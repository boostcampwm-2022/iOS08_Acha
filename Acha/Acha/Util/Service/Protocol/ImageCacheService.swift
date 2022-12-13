//
//  ImageCacheService.swift
//  Acha
//
//  Created by 조승기 on 2022/12/11.
//

import Foundation
import RxSwift

protocol ImageCacheService {
    func isExist(imageURL: String) -> Bool
    func load(imageURL: String) -> Single<Data>
    func write(imageURL: String, image: Data)
}
