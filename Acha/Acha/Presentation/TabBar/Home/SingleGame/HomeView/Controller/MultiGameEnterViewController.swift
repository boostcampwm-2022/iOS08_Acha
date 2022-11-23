//
//  MultiGameEnterViewController.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import UIKit
import Then
import SnapKit

class MultiGameEnterViewController: UIViewController {
    
    private lazy var makeRoomButton: UIButton = UIButton().then {
        $0.backgroundColor = .pointLight
        $0.layer.cornerRadius = 10
        $0.setTitle("방 만들기", for: .normal)
    }
    
    private lazy var enterRoomtButton: UIButton = UIButton().then {
        $0.backgroundColor = .pointLight
        $0.layer.cornerRadius = 10
        $0.setTitle("방 입장", for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layout()
    }

}

extension MultiGameEnterViewController {
    private func layout() {
        addViews()
        addConstraints()
    }
    
    private func addViews() {
        view.addSubview(makeRoomButton)
        view.addSubview(enterRoomtButton)
    }
    
    private func addConstraints() {
        makeRoomButton.snp.makeConstraints {
            $0.top.equalTo(view).offset(100)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(100)
            $0.bottom.equalTo(view.snp.centerY).inset(50)
        }
        
        enterRoomtButton.snp.makeConstraints {
            $0.top.equalTo(makeRoomButton.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(100)
            $0.bottom.equalTo(view.snp.bottom).inset(50)
        }
    }
}
