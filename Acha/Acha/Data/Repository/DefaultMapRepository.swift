//
// DefaultMapRepository.swift
// Acha
//
// Created by 조승기 on 2022/11/27.
//

import RxSwift

final class DefaultMapRepository: MapRepository {
    private let realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService
    private let disposeBag = DisposeBag()
    
    init(realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService) {
        self.realTimeDatabaseNetworkService = realTimeDatabaseNetworkService
    }
    
    func fetchAllMaps() -> Single<[Map]> {
        realTimeDatabaseNetworkService.fetch(type: FirebaseRealtimeType.mapList(id: nil))
    }
    
    func fetchMapsAtLocation(location: String) -> Single<[Map]> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            self.realTimeDatabaseNetworkService.fetchAtKeyValue(type: .mapList(id: nil),
                                          value: location,
                                          key: "location")
            .subscribe(onSuccess: { (maps: [Map?]) in
                single(.success(maps.compactMap {$0}))
            }, onFailure: { _ in
                single(.success([]))
            })
            .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}
