//
//  Badge.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/30.
//

import Foundation

struct Badge: Hashable {
    let id: Int
    let name: String
    let imageURL: String
    let isHidden: Bool
    var isOwn: Bool = false
}
