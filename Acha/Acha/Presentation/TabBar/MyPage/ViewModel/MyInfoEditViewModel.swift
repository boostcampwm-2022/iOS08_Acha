//
//  MyInfoEditViewModel.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/10.
//

import Foundation
import RxSwift
import FirebaseAuth

final class MyInfoEditViewModel: BaseViewModel {
    
    // MARK: - Input
    struct Input {
        var viewWillAppearEvent: Observable<Void>
        var emailText: Observable<String>
        var nickNameText: Observable<String>
        var characterChangeButtonTap: Observable<Void>
        var finishButtonTap: PublishSubject<String>
    }
    // MARK: - Output
    struct Output {
        var userInfo = PublishSubject<(User, String)>()   // user, email
        var pinCharacterUpdated: PublishSubject<String>
        var cannotSave = PublishSubject<Void>()
    }
    var emailValidity: Bool = true
    var nickNameValidity: Bool = true
    var pinCharacterUpdated = PublishSubject<String>()
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private var user: User
    private var userEmail: String = ""
    private var ownedBadges: [Badge]
    
    // MARK: - Dependency
    private weak var coordinator: MyPageCoordinator?
    private let useCase: MyInfoEditUseCase
    
    // MARK: - Lifecycles
    init(coordinator: MyPageCoordinator, useCase: MyInfoEditUseCase, user: User, ownedBadges: [Badge]) {
        self.coordinator = coordinator
        self.useCase = useCase
        self.user = user
        if let email = Auth.auth().currentUser?.email {
            self.userEmail = email
        }
        self.ownedBadges = ownedBadges
    }
    
    // MARK: - Helpers
    func transform(input: Input) -> Output {
        let output = Output(pinCharacterUpdated: pinCharacterUpdated)
        
        input.viewWillAppearEvent
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                output.userInfo.onNext((self.user, self.userEmail))
            }).disposed(by: disposeBag)
        
        input.emailText
            .skip(1)    // 초기값 ""이 전달되어 skip
            .subscribe(onNext: { [weak self] email in
                guard let self else { return }
                if self.useCase.emailValidate(text: email) {
                    self.userEmail = email
                    self.emailValidity = true
                } else {
                    self.emailValidity = false
                }
            }).disposed(by: disposeBag)
        
        input.nickNameText
            .skip(1)
            .subscribe(onNext: { [weak self] nickName in
                guard let self else { return }
                if nickName.count > 0 {
                    self.nickNameValidity = true
                    self.user.nickName = nickName
                } else {
                    self.nickNameValidity = false
                }
            }).disposed(by: disposeBag)
        
        input.characterChangeButtonTap
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator?.showCharacterSelectViewController(delegate: self)
            }).disposed(by: disposeBag)
        
        input.finishButtonTap
            .subscribe(onNext: { [weak self] password in
                guard let self else { return }
                if !self.emailValidity || !self.nickNameValidity {
                    output.cannotSave.onNext(())
                } else {
                    self.useCase.updateUserInfo(user: self.user, email: self.userEmail, password: password)
                        .subscribe(onSuccess: { [weak self] in
                            guard let self,
                                  let coordinator = self.coordinator else { return }
                            coordinator.navigationController.viewControllers.last?.view.rx.indicator.onNext(false)
                            coordinator.didFinished(childCoordinator: coordinator)
                        }, onFailure: { error in
                            print(error)
                            output.cannotSave.onNext(())
                        })
                        .disposed(by: self.disposeBag)
                }
            }).disposed(by: disposeBag)
        
        return output
    }
}

extension MyInfoEditViewModel: CharacterSelectViewModelDelegate {
    func deliverSelectedCharacter(imageURL: String) {
        user.pinCharacter = imageURL
        self.pinCharacterUpdated.onNext(imageURL)
    }
}
