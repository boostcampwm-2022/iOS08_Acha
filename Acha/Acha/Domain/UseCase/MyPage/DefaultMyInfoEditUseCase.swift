//
//  DefaultMyInfoEditUseCase.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/10.
//

import Foundation
import RxSwift

final class DefaultMyInfoEditUseCase: MyInfoEditUseCase {
    
    // MARK: - Properties
    private let userRepository: UserRepository
    private var disposeBag = DisposeBag()
    
    // MARK: - Lifecycles
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    // MARK: - Helpers
    func emailValidate(text: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return text.stringCheck(pattern: pattern)
    }
    
    func updateUserInfo(user: User, email: String, password: String) -> Single<Void> {
        Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            self.userRepository.updateUserEmail(email: email, password: password)
                .subscribe(onSuccess: { [weak self] _ in
                    guard let self else { return }
                    self.userRepository.updateUserData(user: user)
                        .subscribe(onSuccess: {
                            single(.success(()))
                        }, onFailure: { error in
                            single(.failure(error))
                        })
                        .disposed(by: self.disposeBag)
                }, onFailure: {
                    single(.failure($0))
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
}
