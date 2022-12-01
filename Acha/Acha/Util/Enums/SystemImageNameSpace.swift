//
//  SystemImageNameSpace.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/15.
//

import UIKit

enum SystemImageNameSpace: String {
    case locationCircle = "location.circle"
    case ellipsis = "ellipsis"
    case xmark = "xmark"
    
    var uiImage: UIImage { UIImage(systemName: self.rawValue) ?? UIImage() }
    
    func systemImageColorChange(color: UIColor) -> UIImage {
        return self.uiImage.withTintColor(color, renderingMode: .alwaysOriginal)
    }
}
