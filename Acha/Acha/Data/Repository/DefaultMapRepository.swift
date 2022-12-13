//
// DefaultMapRepository.swift
// Acha
//
// Created by 조승기 on 2022/11/27.
//

import RxSwift

final class DefaultMapRepository: MapRepository {
    private let realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService
    private let firebaseStorageNetworkService: FirebaseStorageNetworkService
    private let imageCacheService: ImageCacheService
    
    init(
        realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService,
        firebaseStorageNetworkService: FirebaseStorageNetworkService,
        imageCacheService: ImageCacheService
    ) {
        self.realTimeDatabaseNetworkService = realTimeDatabaseNetworkService
        self.firebaseStorageNetworkService = firebaseStorageNetworkService
        self.imageCacheService = imageCacheService
    }
    
    func fetchAllMaps() -> Observable<[Map]> {
        realTimeDatabaseNetworkService.fetch(type: FirebaseRealtimeType.mapList(id: nil))
            .asObservable()
            .flatMap { (mapDTOs: [MapDTO]) in
                Observable.zip(mapDTOs.map { mapDTO in
                    if self.imageCacheService.isExist(imageURL: mapDTO.image) {
                        return self.imageCacheService.load(imageURL: mapDTO.image)
                            .asObservable()
                            .map { data in
                                Map(mapID: mapDTO.mapID,
                                    name: mapDTO.name,
                                    centerCoordinate: mapDTO.centerCoordinate.toDomain(),
                                    coordinates: mapDTO.coordinates.map { $0.toDomain() },
                                    location: mapDTO.location,
                                    image: data)
                            }
                    }
                    
                    return self.firebaseStorageNetworkService.download(urlString: mapDTO.image)
                        .map { data -> Map in
                            self.imageCacheService.write(imageURL: mapDTO.image, image: data)
                            return Map(mapID: mapDTO.mapID,
                                       name: mapDTO.name,
                                       centerCoordinate: mapDTO.centerCoordinate.toDomain(),
                                       coordinates: mapDTO.coordinates.map { $0.toDomain() },
                                       location: mapDTO.location,
                                       image: data)
                        }
                })
            }
    }
}
