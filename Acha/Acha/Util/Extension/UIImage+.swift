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
    static let plusImage: UIImage = UIImage(systemName: "plus")!
    static let penguinImage = UIImage(named: "penguin") ?? UIImage()
    static let xImage = UIImage(named: "x.circle.fill") ?? UIImage()
    static let firstAnnotation = UIImage(named: "firstAnnotation") ?? UIImage()
    static let secondAnnotation = UIImage(named: "secondAnnotation") ?? UIImage()
    static let thirdAnnotation = UIImage(named: "thirdAnnotation") ?? UIImage()
    static let fourthAnnotation = UIImage(named: "fourthAnnotation") ?? UIImage()
    static let systemEyeCircle = UIImage(
        systemName: "eye.circle",
        withConfiguration: UIImage.SymbolConfiguration(
            pointSize: 30,
            weight: .bold,
            scale: .large
        )
    )
    
    func imageWith(newSize: CGSize) -> UIImage {
        let image = UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
            
        return image.withRenderingMode(renderingMode)
    }
}
