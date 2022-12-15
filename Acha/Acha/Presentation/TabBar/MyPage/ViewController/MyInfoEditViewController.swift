//
//  MyInfoEditViewController.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/01.
//

import UIKit
import SnapKit
import Then
import RxSwift

final class MyInfoEditViewController: UIViewController {
    
    // MARK: - UI properties
    private let emailTextFieldView = InfoTextFieldView(frame: CGRect(), title: "이메일")
    private let nickNameTextFieldView = InfoTextFieldView(frame: CGRect(), title: "닉네임")
    private let characterLabel: UILabel = UILabel().then {
        $0.text = "대표 캐릭터"
        $0.textColor = .pointLight
        $0.font = .title
    }
    private let characterImageView: UIImageView = UIImageView().then {
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
    private let viewModel: MyInfoEditViewModel
    private var disposeBag = DisposeBag()
    private var finishButtonTap = PublishSubject<String>()
    
    // MARK: - Lifecycles
    init(viewModel: MyInfoEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
    }
}

extension MyInfoEditViewController {
    private func configureUI() {
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "내 정보 수정"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.pointLight]
        navigationController?.navigationBar.tintColor = .pointLight
        view.backgroundColor = .white
        
        view.addSubview(emailTextFieldView)
        view.addSubview(nickNameTextFieldView)
        view.addSubview(characterLabel)
        view.addSubview(characterImageView)
        view.addSubview(characterChangeButton)
        view.addSubview(finishButton)
        
        emailTextFieldView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(30)
            $0.height.equalTo(40)
        }
        nickNameTextFieldView.snp.makeConstraints {
            $0.top.equalTo(emailTextFieldView.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(emailTextFieldView)
            $0.height.equalTo(emailTextFieldView)
        }
        characterLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameTextFieldView.snp.bottom).offset(20)
            $0.leading.equalTo(emailTextFieldView)
            $0.height.equalTo(emailTextFieldView)
        }
        characterImageView.snp.makeConstraints {
            $0.top.equalTo(characterLabel.snp.bottom).offset(10)
            $0.leading.equalTo(emailTextFieldView)
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
    
    private func bind() {
        let input = MyInfoEditViewModel.Input(
            viewWillAppearEvent: rx.viewWillAppear.asObservable(),
            emailText: emailTextFieldView.textField.rx.text.orEmpty.asObservable(),
            nickNameText: nickNameTextFieldView.textField.rx.text.orEmpty.asObservable(),
            characterChangeButtonTap: characterChangeButton.rx.tap.asObservable(),
            finishButtonTap: finishButtonTap
        )
        let output = viewModel.transform(input: input)
        
        output.userInfo
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (user, email) in
                guard let self else { return }
                self.emailTextFieldView.setContent(email)
                self.nickNameTextFieldView.setContent(user.nickName)
                self.characterImageView.image = PinCharacter(rawValue: user.pinCharacter)?.image
            })
            .disposed(by: disposeBag)
        
        output.pinCharacterUpdated
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] pinCharacterURL in
                guard let self else { return }
                self.characterImageView.image = PinCharacter(rawValue: pinCharacterURL)?.image
            })
            .disposed(by: disposeBag)
        
        output.cannotSave
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showAlert(title: "이메일 혹은 닉네임이 유효하지 않습니다", message: "다시 입력해주세요")
            })
            .disposed(by: disposeBag)
        
        configureFinishButton()
    }
    
    private func configureFinishButton() {
        finishButton.rx.tap
            .asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.showTextFieldAlert(title: "정보를 수정하기 위해 비밀번호를 입력해주세요",
                                        message: "",
                                        actionTitle: "확인",
                                        actionHandler: { password in
                    self.finishButtonTap.onNext(password)
                    self.view.rx.indicator.onNext(true)
                })
            })
            .disposed(by: disposeBag)
    }
}
