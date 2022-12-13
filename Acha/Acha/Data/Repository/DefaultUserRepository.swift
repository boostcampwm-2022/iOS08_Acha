//
//  DefaultUserRepository.swift
//  Acha
//
//  Created by hong on 2022/12/02.
//
import Foundation
import RxSwift

struct DefaultUserRepository: UserRepository {
    
    private let realtimeDataBaseService: RealtimeDatabaseNetworkService
    private let keychainService: KeychainService
    private let authService: AuthService
    private let disposeBag = DisposeBag()
    
    enum UserError: Error {
        case signOutError
    }
    
    init(
        realtimeDataBaseService: RealtimeDatabaseNetworkService,
        keychainService: KeychainService,
        authService: AuthService
    ) {
        self.realtimeDataBaseService = realtimeDataBaseService
        self.keychainService = keychainService
        self.authService = authService
    }
    
    func getUUID() -> String? {
        return keychainService.get()
    }
    
    func fetchUserData() -> Single<User> {
        return Single<User>.create { single in
            guard let uuid = getUUID() else {
                single(.failure(KeyChainManager.KeychainServiceError.notLogined))
                return Disposables.create()
            }
            getUserDataFromRealTimeDataBaseService(uuid: uuid)
                .subscribe { userDTO in
                    single(.success(userDTO.toDomain()))
                }
                .disposed(by: disposeBag)
            return Disposables.create()
        }
    }
    
    func signUp(data: SignUpData) -> Single<UserDTO> {
        return authService.signUp(data: data)
            .map { userDTO in
                uploadUserData(data: userDTO)
                loginDataUpdate(uuid: userDTO.id)
                return userDTO
            }
    }
    
    func logIn(data: LoginData) -> Single<String> {
        return authService.logIn(data: data)
            .map { uuid in
                loginDataUpdate(uuid: uuid)
                return uuid
            }
    }
    
    private func loginDataUpdate(uuid: String) {
        keychainService.delete()
        keychainService.save(uuid: uuid)
    }
    
    func signOut() -> Observable<Void> {
        
        return Observable<Void>.create { observer in
            do {
                try authService.signOut()
                keychainService.delete()
                guard getUUID() == nil else {
                    observer.onError(UserError.signOutError)
                    return Disposables.create()
                }
                observer.onNext(())
            } catch {
                observer.onError(UserError.signOutError)
            }
            
            return Disposables.create()
        }
    
    }
    
    func delete() -> Single<Void> {
        // auth에서 제거
        authService.delete()
            .map {
                // 디비에서 제거
                guard let uuid = getUUID() else { return }
                realtimeDataBaseService.delete(type: .user(id: uuid))
                
                // 키체인에서 제거
                keychainService.delete()
                guard getUUID() == nil else {
                    throw UserError.signOutError
                }
            }
    }
    

    func updateUserData(user: User) -> Single<Void> {
        Single.create { single in
            guard let uuid = getUUID() else {
                return Disposables.create()
            }
            getUserDataFromRealTimeDataBaseService(uuid: uuid)
                .subscribe(onSuccess: { userDTO in
                    let updatedUserDTO = UserDTO(id: userDTO.id,
                                                 nickname: user.nickName,
                                                 badges: user.badges,
                                                 records: user.records,
                                                 pinCharacter: user.pinCharacter,
                                                 friends: user.friends)
                    realtimeDataBaseService
                        .upload(type: .user(id: updatedUserDTO.id), data: updatedUserDTO)
                        .subscribe(onSuccess: {
                            single(.success(()))
                        }, onFailure: { error in
                            single(.failure(error))
                        })
                        .disposed(by: disposeBag)
                })
                .disposed(by: disposeBag)
            return Disposables.create()
        }
    }
    
    func updateUserEmail(email: String, password: String) -> Single<Void> {
        authService.update(email: email, password: password)
    }
    
    private func uploadUserData(data: UserDTO) {
        realtimeDataBaseService.upload(type: .user(id: data.id), data: data)
    }
    
    private func getUserDataFromRealTimeDataBaseService(uuid: String) -> Single<UserDTO> {
        return realtimeDataBaseService.fetch(type: .user(id: uuid))
    }
}
