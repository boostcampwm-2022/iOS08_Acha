//
//  DefaultBadgeRepository.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/01.
//

import RxSwift
import Foundation

final class DefaultBadgeRepository: BadgeRepository {
    private let realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService
    private let firebaseStorageNetworkService: FirebaseStorageNetworkService
    private let imageCacheService: ImageCacheService
    private var disposeBag = DisposeBag()
    
    init(
        realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService,
        firebaseStorageNetworkService: FirebaseStorageNetworkService,
        imageCacheService: ImageCacheService
    ) {
        self.realTimeDatabaseNetworkService = realTimeDatabaseNetworkService
        self.firebaseStorageNetworkService = firebaseStorageNetworkService
        self.imageCacheService = imageCacheService
    }
    
    func fetchAllBadges() -> Observable<[Badge]> {
        realTimeDatabaseNetworkService.fetch(type: FirebaseRealtimeType.badge)
            .asObservable()
            .flatMap { (badgeDTOs: [BadgeDTO]) in
                Observable.zip(badgeDTOs.map { badgeDTO in
                    if let data = self.imageCacheService.load(imageURL: badgeDTO.imageURL) {
                        return Observable.of(badgeDTO.toDomain(image: data))
                    }
                    
                    return self.firebaseStorageNetworkService.download(urlString: badgeDTO.imageURL)
                        .map { data -> Badge in
                            self.imageCacheService.write(imageURL: badgeDTO.imageURL, image: data)
                            return badgeDTO.toDomain(image: data)
                        }
                })
            }
    }
    
    func fetchSomeBadges(ids: [Int]) -> Observable<[Badge]> {
        fetchAllBadges()
            .map { (badges: [Badge]) -> [Badge] in
                return badges.filter { ids.contains($0.id) }
            }
    }
}
