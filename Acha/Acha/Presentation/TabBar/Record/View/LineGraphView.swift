//
//  LineGraphView.swift
//  Acha
//
//  Created by 배남석 on 2022/11/28.
//

import UIKit
import SnapKit
import Then

class LineGraphView: UIView {
    
    var values: [CGFloat] = []
    
    var graphPath: UIBezierPath!
    var zeroPath: UIBezierPath!
    var dotPath: UIBezierPath!
    
    let graphLayer = CAShapeLayer().then {
        $0.fillColor = nil
        $0.strokeColor = UIColor.pointLight.cgColor
        $0.lineWidth = 3
    }
    
    let dotLayer = CAShapeLayer().then {
        $0.fillColor = UIColor.pointLight.cgColor
    }

    init(frame: CGRect, values: [CGFloat]) {
        super.init(frame: frame)
        self.values = values
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.graphPath = UIBezierPath()
        self.zeroPath = UIBezierPath()
        self.dotPath = UIBezierPath()
        
        self.layer.addSublayer(graphLayer)

        var heightPerMeter: Double = 0
        if let maxDistance = values.max(), maxDistance != 0 {
            let chartHeight = 360.0
            heightPerMeter = chartHeight / maxDistance
        }
        
        let xOffset: CGFloat = self.frame.width / CGFloat(values.count)
        
        var currentX: CGFloat = (self.frame.width / CGFloat(values.count)) / 2
        let startPosition = CGPoint(x: currentX, y: self.frame.height - self.values[0] * heightPerMeter)
        self.graphPath.move(to: startPosition)
        self.zeroPath.move(to: startPosition)
        self.dotPath.move(to: startPosition)
        self.dotPath.addArc(withCenter: startPosition, radius: 5, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        
        for index in 1..<values.count {
            currentX += xOffset
            let newPosition = CGPoint(x: currentX,
                                      y: self.frame.height - self.values[index] * heightPerMeter)
            
            self.graphPath.addLine(to: newPosition)
            self.zeroPath.addLine(to: CGPoint(x: currentX, y: self.frame.height))
            self.dotPath.move(to: newPosition)
            self.dotPath.addArc(withCenter: newPosition, radius: 5, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        }
        
        let oldPath = self.zeroPath.cgPath
        let newPath = self.graphPath.cgPath
            
        let animation = CABasicAnimation(keyPath: AnimationKeyPath.path.string)
        animation.duration = 1
        animation.fromValue = oldPath
        animation.toValue = newPath
        self.graphLayer.add(animation, forKey: AnimationKeyPath.path.string)
        self.graphLayer.path = newPath
  
        let dotAnimation = CABasicAnimation(keyPath: AnimationKeyPath.opacity.string)
        dotAnimation.duration = 1
        dotAnimation.fromValue = 0.0
        dotAnimation.toValue = 2.0
        self.dotLayer.add(dotAnimation, forKey: AnimationKeyPath.opacity.string)
        self.dotLayer.path = dotPath.cgPath
        
        self.layer.addSublayer(dotLayer)
    }
}
