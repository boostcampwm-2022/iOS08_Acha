//
//  Rx+IndicatorAnimation.swift
//  Acha
//
//  Created by hong on 2022/12/09.
//

import UIKit
import RxSwift
import Then

extension Reactive where Base: UIView {
    
    var indicator: Binder<Bool> {
        Binder(base) { base, indicator in

            if indicator {
                let backView = UIView(frame: base.frame).then {
                    $0.alpha = 0.6
                    $0.backgroundColor = .black
                    $0.tag = 444
                }
                let image = UIButton().then {
                    base.isUserInteractionEnabled = false
                    $0.layer.borderColor = UIColor.blue.cgColor
                    $0.layer.borderWidth = 4
                    $0.layer.cornerRadius = 10
                    $0.frame.size = CGSize(width: 60, height: 60)
                    $0.tag = 444
                }
                base.addSubview(backView)
                backView.addSubview(image)
                image.center = base.center
                image.layer.add(animationGroup, forKey: nil)
            } else {
                base.isUserInteractionEnabled = true
                base.subviews.forEach { if $0.tag == 444 {
                    $0.removeFromSuperview()
                } }
            }
        }
    }
    
    var animationGroup: CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 0.6
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        animationGroup.repeatCount = .infinity
        
        let animation3 = CABasicAnimation(keyPath: "position.x")
        animation3.fromValue = base.center.x-100
        animation3.toValue = base.center.x + 100
        
        let animation5 = CABasicAnimation(keyPath: "transform.rotation.x")
        animation5.fromValue = 0
        animation5.toValue = Double.pi / 3
        
        animationGroup.animations = [animation3, animation5]
        
        return animationGroup
    }
}
