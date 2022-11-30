//
//  AnimationKeyPath.swift
//  Acha
//
//  Created by 배남석 on 2022/11/30.
//

import Foundation

enum AnimationKeyPath {
    case path
    case opacity
    
    var string: String {
        switch self {
        case .path:
            return "path"
        case .opacity:
            return "opacity"
        }
    }
}
