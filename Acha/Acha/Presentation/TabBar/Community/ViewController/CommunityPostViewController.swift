//
//  CommunityPostViewController.swift
//  Acha
//
//  Created by hong on 2022/11/29.
//

import UIKit
import Then
import SnapKit

final class CommunityPostViewController: ScrollAbleViewController {
    
    private lazy var postWirteView = UIView().then {
        $0.layer.cornerRadius = 10
        $0.layer?.borderWidth = 2
        $0.layer.borderColor = UIColor.pointDark.cgColor()
    }
    private lazy var postWriteTextView = UItextview()
    private lazy var imageAddButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
