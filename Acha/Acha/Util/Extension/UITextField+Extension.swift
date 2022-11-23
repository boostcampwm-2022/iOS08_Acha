//
//  UITextField+Extension.swift
//  Acha
//
//  Created by hong on 2022/11/21.
//

import UIKit

extension UITextField {
    
    enum IconLocation {
        case left
        case right
    }
    
    func setIcon(image: UIImage, location: IconLocation) {
        let iconView = UIImageView(
            frame: CGRect(x: 10,
                          y: 5,
                          width: 20,
                          height: 20)
        )
        iconView.image = image
        let iconContainerView: UIView = UIView(
            frame: CGRect(x: 50,
                          y: 0,
                          width: 40,
                          height: 30)
        )
        iconContainerView.addSubview(iconView)
        switch location {
        case .left:
            leftView = iconContainerView
            leftViewMode = .always
        case .right:
            rightView = iconContainerView
            rightViewMode = .unlessEditing
        }
    }

}
