//
//  MultiGameEnterViewController.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import UIKit
import Then
import SnapKit

final class MultiGameEnterViewController: UIViewController {
    
    lazy var makeRoomButton: UIButton = UIButton().then {
        $0.backgroundColor = .pointLight
        $0.layer.cornerRadius = 10
        $0.setTitle("방 만들기", for: .normal)
    }
    
    lazy var enterRoomtButton: UIButton = UIButton().then {
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
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(100)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(100)
            $0.bottom.equalTo(view.snp.centerY).inset(-100)
        }
        
        enterRoomtButton.snp.makeConstraints {
            $0.top.equalTo(makeRoomButton.snp.bottom).inset(-50)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(100)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(100)
        }
    }
}
