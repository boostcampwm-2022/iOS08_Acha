//
//  MultiGameEnterViewController.swift
//  Acha
//
//  Created by hong on 2022/11/26.
//

import UIKit
import SnapKit
import Then

final class MultiGameEnterViewController: UIViewController {
    
    lazy var makeRoomButton: UIButton = UIButton().then {
        $0.backgroundColor = .pointLight
        $0.layer.cornerRadius = 10
        $0.setTitle("방 만들기", for: .normal)
        $0.titleLabel?.font = .largeTitle
        $0.setImage(.homeImage, for: .normal)
        $0.semanticContentAttribute = .forceLeftToRight
        $0.imageView?.contentMode = .scaleAspectFit
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: -75, bottom: 0, right: 15)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 75, bottom: 0, right: 0)
    }
    
    lazy var enterRoomtButton: UIButton = UIButton().then {
        $0.backgroundColor = .pointLight
        $0.layer.cornerRadius = 10
        $0.setTitle("방 입장", for: .normal)
        $0.titleLabel?.font = .largeTitle
        $0.setImage(.magnyfingGlassImage, for: .normal)
        $0.semanticContentAttribute = .forceLeftToRight
        $0.imageView?.contentMode = .scaleAspectFit
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: -75, bottom: 0, right: 15)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 75, bottom: 0, right: 0)
        
    }
    
    lazy var conatinerView: UIView = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    lazy var dimmedView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
    
}

extension MultiGameEnterViewController {
    
    private func layout() {
        view.backgroundColor = .clear
        addViews()
        addConstraints()
    }
    
    private func addViews() {
        view.addSubview(dimmedView)
        view.addSubview(conatinerView)
        conatinerView.addSubview(makeRoomButton)
        conatinerView.addSubview(enterRoomtButton)
    }
    
    private func addConstraints() {
        dimmedView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(500)
        }
        
        conatinerView.snp.makeConstraints {
            $0.top.equalTo(dimmedView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        makeRoomButton.snp.makeConstraints {
            $0.top.equalTo(dimmedView.snp.bottom).inset(-40)
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(150)
        }
        
        enterRoomtButton.snp.makeConstraints {
            $0.top.equalTo(makeRoomButton.snp.bottom).inset(-50)
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(150)
        }
    }

}
