//
//  UIButton+.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/15.
//

import UIKit

extension UIButton {
    
    var isValid: Bool {
        get {
            isEnabled
        }
        set {
            self.isEnabled = newValue
            self.alpha = newValue ? 1.0 : 0.5
        }
    }
    
}
