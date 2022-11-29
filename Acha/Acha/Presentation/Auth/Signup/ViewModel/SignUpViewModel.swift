//
//  SignUpViewModel.swift
//  Acha
//
//  Created by hong on 2022/11/21.
//

import Foundation
import RxSwift
import RxCocoa

final class SignUpViewModel {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    struct Input {
        let passwordUpdated: Observable<String>
        let nickNameUpdated: Observable<String>
        let emailUpdated: Observable<String>
        let signUpButtonDidTap: Observable<Void>
        let logInButtonDidTap: Observable<Void>
    }
    
    struct Output {
        let passwordValidated: Observable<Bool>
        let nickNameValidated: Observable<Bool>
        let emailValidated: Observable<Bool>
        let signUpSuccesssed: Observable<Bool>
    }
    
    typealias SignUpUseCase = SignUpAble
    & EmailValidate
    & PasswordValidate
    & NickNameValidate
    & UserDataAppendToDatabase
    
    private let useCase: SignUpUseCase
    private weak var coordinator: SignupCoordinatorProtocol?
    private var repository: SignUpRepository
    
    init(
        coordinator: SignupCoordinatorProtocol,
        useCase: SignUpUseCase,
        repository: SignUpRepository
    ) {
        self.useCase = useCase
        self.coordinator = coordinator
        self.repository = repository
    }
  
    // FIXME: 데이터 스트림이 남아 있어 메모리 누수가 발생할 수 있습니다. deinit 시점 초기화를 통해 메모리 누수를 방지하면 좋을거 같아요
    deinit {
      disposeBag = DisposeBag()
    }
    
    func transform(input: Input) -> Output {
        
        // 별도의 DisposeBag를 생성하고 disposeBag에 주입하는 이유가 있을까요?
        let bag = DisposeBag()
        let paswordValidate =  Observable<Bool>.create { observer in
            input.passwordUpdated
                .subscribe(onNext: { [weak self] text in
                    guard let self = self else {return}
                    if self.useCase.passwordValidate(text: text) {
                        self.repository.passwordValidation = true
                        self.repository.passwordRelay.accept(text)
                        observer.onNext(true)
                    } else {
                        self.repository.passwordValidation = false
                        observer.onNext(false)
                    }
                })
                .disposed(by: bag)
            return Disposables.create()
        }
        
        let emailValidate = Observable<Bool>.create { observer in
            input.emailUpdated
                .subscribe { [weak self] text in
                    guard let self = self else {return}
                    if self.useCase.emailValidate(text: text) {
                        self.repository.emailValidation = true
                        self.repository.emailRelay.accept(text)
                        observer.onNext(true)
                    } else {
                        self.repository.emailValidation = false
                        observer.onNext(false)
                    }
                }
                .disposed(by: bag)
            return Disposables.create()
        }
        
        let nickNameValidate = Observable<Bool>.create { observer in
            input.nickNameUpdated
                .subscribe { [weak self] text in
                    guard let self = self else {return}
                    if self.useCase.nickNameValidate(text: text) {
                        self.repository.nickNameValidation = true
                        self.repository.nickNameRelay.accept(text)
                        observer.onNext(true)
                    } else {
                        self.repository.nickNameValidation = false
                        observer.onNext(false)
                    }
                }
                .disposed(by: bag)
            return Disposables.create()
        }
        
        input.logInButtonDidTap
            .subscribe { [weak self] _ in
                self?.coordinator?.showLoginViewController()
            }
            .disposed(by: bag)
        
        let signUpButtonDidTap = Observable<Bool>.create { observer in
            input.signUpButtonDidTap
                .subscribe { [weak self] _ in
                    self?.repository.getSignUpdata()
                        .distinctUntilChanged()
                        .subscribe(onNext: { signUpData in
                            guard let self = self else {return}
                            if self.repository.isSignAble() {
                                self.useCase.signUp(data: signUpData)
                                    .subscribe(onNext: { result in
                                        switch result {
                                        case .failure(_):
                                            observer.onNext(false)
                                        case .success(let uid):
                                            let userData = signUpData.toUserDTO(id: uid)
                                            self.useCase.userDataAppendToDatabase(userData: userData)
                                            self.transitionView()
                                        }
                                    })
                                    .disposed(by: bag)
                            } else {
                                observer.onNext(false)
                            }
                        })
                        .disposed(by: bag)
                }
                .disposed(by: bag)
            return Disposables.create()
        }
        
        disposeBag = bag

        return Output(passwordValidated: paswordValidate,
                      nickNameValidated: nickNameValidate,
                      emailValidated: emailValidate,
                      signUpSuccesssed: signUpButtonDidTap)
    }
    
    private func transitionView() {
        guard let strongCoordinator = coordinator else {return}
        strongCoordinator.delegate?.didFinished(childCoordinator: strongCoordinator)
    }
    
}
