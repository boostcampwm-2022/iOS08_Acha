//
//  PinCharacter.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/13.
//

import UIKit

enum PinCharacter: String, CaseIterable {
    case firstAnnotation
    case secondAnnotation
    case thirdAnnotation
    case fourthAnnotation
    
    var image: UIImage {
        UIImage(named: self.rawValue) ?? .firstAnnotation
    }
    
    var name: String {
        switch self {
        case .firstAnnotation:
            return "펭귄"
        case .secondAnnotation:
            return "강아지"
        case .thirdAnnotation:
            return "고양이"
        case .fourthAnnotation:
            return "토끼"
        }
    }
}
