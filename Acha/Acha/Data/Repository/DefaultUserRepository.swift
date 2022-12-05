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
                return userDTO
            }
    }
    
    func logIn(data: LoginData) -> Single<String> {
        return authService.logIn(data: data)
            .map { uuid in
                keychainService.save(uuid: uuid)
                return uuid
            }
    }
    
    func signOut() -> Observable<Void> {
        
        return Observable<Void>.create { observer in
            do {
                try authService.signOut()
                guard getUUID() == nil else {
                    observer.onError(UserError.signOutError)
                    return Disposables.create()
                }
                keychainService.delete()
            } catch {
                observer.onError(UserError.signOutError)
            }
            
            return Disposables.create()
        }
    
    }
    
    private func uploadUserData(data: UserDTO) {
        realtimeDataBaseService.upload(type: .user(id: data.id), data: data)
    }
    
    private func getUserDataFromRealTimeDataBaseService(uuid: String) -> Single<UserDTO> {
        return realtimeDataBaseService.fetch(type: .user(id: uuid))
    }
}
