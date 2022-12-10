//
//  MyInfoEditViewController.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/01.
//

import UIKit
import FirebaseAuth
import SnapKit
import Then

final class MyInfoEditViewController: UIViewController {
    
    // MARK: - UI properties
    private let idTextFieldView = InfoTextFieldView(frame: CGRect(), title: "아이디", content: "deunggi@acha.com")
    private let nickNameTextFieldView = InfoTextFieldView(frame: CGRect(), title: "닉네임", content: "승기바보")
    private let characterLabel: UILabel = UILabel().then {
        $0.text = "대표 캐릭터"
        $0.textColor = .pointLight
        $0.font = .title
    }
    private let characterImageView: UIImageView = UIImageView().then {
        $0.image = .penguinImage
        $0.contentMode = .scaleAspectFit
        $0.layer.borderWidth = 3
        $0.layer.borderColor = UIColor.pointLight.cgColor
        $0.layer.cornerRadius = 50
        $0.clipsToBounds = true
    }
    private let characterChangeButton: UIButton = UIButton().then {
        $0.setTitle("변경", for: .normal)
        $0.setTitleColor(.gray, for: .normal)
        $0.titleLabel?.font = .commentBody
    }
    private let finishButton: UIButton = UIButton().then {
        $0.setTitle("수정하기", for: .normal)
        $0.backgroundColor = .pointLight
        $0.layer.cornerRadius = 10
        $0.titleLabel?.font = .postBody
    }

    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        guard let user = Auth.auth().currentUser else { return }
        print(user.email)
        print(user.uid)
    }
}

extension MyInfoEditViewController {
    private func configureUI() {
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "내 정보 수정"
        view.backgroundColor = .white
        
        view.addSubview(idTextFieldView)
        view.addSubview(nickNameTextFieldView)
        view.addSubview(characterLabel)
        view.addSubview(characterImageView)
        view.addSubview(characterChangeButton)
        view.addSubview(finishButton)
        
        idTextFieldView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(30)
            $0.height.equalTo(40)
        }
        nickNameTextFieldView.snp.makeConstraints {
            $0.top.equalTo(idTextFieldView.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(idTextFieldView)
            $0.height.equalTo(idTextFieldView)
        }
        characterLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameTextFieldView.snp.bottom).offset(20)
            $0.leading.equalTo(idTextFieldView)
            $0.height.equalTo(idTextFieldView)
        }
        characterImageView.snp.makeConstraints {
            $0.top.equalTo(characterLabel.snp.bottom).offset(10)
            $0.leading.equalTo(idTextFieldView)
            $0.width.height.equalTo(100)
        }
        characterChangeButton.snp.makeConstraints {
            $0.centerY.equalTo(characterLabel)
            $0.leading.equalTo(characterLabel.snp.trailing).offset(10)
        }
        finishButton.snp.makeConstraints {
            $0.top.equalTo(characterImageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(90)
            $0.height.equalTo(40)
        }
    }
}
