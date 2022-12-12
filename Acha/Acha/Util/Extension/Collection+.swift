//
//  Collection+.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/12.
//

import Foundation

extension Collection {
    // index에 해당하는 원소를 리턴. 없으면 nil
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
