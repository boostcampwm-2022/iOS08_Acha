//
//  UILabel+Extension.swift
//  Acha
//
//  Created by hong on 2022/11/15.
//

import UIKit

final class PaddingLabel: UILabel {
    let topInset: CGFloat
    let bottomInset: CGFloat
    let leftInset: CGFloat
    let rightInset: CGFloat
    
    init(
        topInset: CGFloat?,
        bottomInset: CGFloat?,
        leftInset: CGFloat?,
        rightInset: CGFloat?
    ) {
        self.topInset = topInset ?? 0
        self.bottomInset = bottomInset ?? 0
        self.leftInset = leftInset ?? 0
        self.rightInset = rightInset ?? 0
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(
            top: topInset,
            left: leftInset,
            bottom: bottomInset,
            right: rightInset
        )
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let newWidth = size.width + leftInset + rightInset
        let newHeight = size.height + topInset + bottomInset
        return CGSize(width: newWidth, height: newHeight)
    }
    
    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}
