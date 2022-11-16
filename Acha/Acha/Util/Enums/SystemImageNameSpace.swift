//
//  SystemImageNameSpace.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/15.
//

import UIKit

enum SystemImageNameSpace: String {
    case locationCircle = "location.circle"
    
    var uiImage: UIImage? { UIImage(systemName: self.rawValue) }
}
