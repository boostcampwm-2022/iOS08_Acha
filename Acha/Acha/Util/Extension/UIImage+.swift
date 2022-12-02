//
//  UIImage+Extension.swift
//  Acha
//
//  Created by hong on 2022/11/22.
//

import UIKit

extension UIImage {
    static let authInvalidateImage: UIImage = UIImage(named: "invalidate")!
    static let homeImage: UIImage = UIImage(named: "home")!
    static let magnyfingGlassImage: UIImage = UIImage(named: "magnifyingGlass")!
    static let exitImage: UIImage = UIImage(named: "exitImage")!
    static let commentImage: UIImage = UIImage(named: "commentImage")!
    static let defaultSelectImage: UIImage = UIImage(named: "defaultSelectImage") ?? UIImage()
    static let ellipsisImage: UIImage = UIImage(systemName: "ellipsis")!
        .withTintColor(.pointDark, renderingMode: .alwaysOriginal)
}
