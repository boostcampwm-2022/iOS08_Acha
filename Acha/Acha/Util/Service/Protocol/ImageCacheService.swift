//
//  ImageCacheService.swift
//  Acha
//
//  Created by 조승기 on 2022/12/11.
//

import Foundation

protocol ImageCacheService {
    func load(imageURL: String) -> Data?
    func write(imageURL: String, image: Data)
}
