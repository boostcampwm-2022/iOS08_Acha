//
//  DefaultSelectMapUseCase.swift
//  Acha
//
//  Created by 조승기 on 2022/11/27.
//

import Foundation
import RxSwift

final class DefaultSelectMapUseCase: DefaultMapBaseUseCase, SelectMapUseCase {
    
    private let mapRepository: MapRepository
    private let recordRepository: RecordRepository
    private var disposeBag = DisposeBag()
    
    var selectedMap: Map?
    private var maps: [Map] = []
    private var visbleMapsIdx: [Int] = []
    
    init(locationService: LocationService,
         mapRepository: MapRepository,
         userRepository: UserRepository,
         recordRepository: RecordRepository) {
        self.mapRepository = mapRepository
        self.recordRepository = recordRepository
        super.init(locationService: locationService,
                   userRepository: userRepository)
    }
    
    override func start() {
        super.start()
        mapRepository.fetchAllMaps()
            .subscribe(onNext: { [weak self] maps in
                guard let self else { return }
                self.maps = maps
            })
            .disposed(by: disposeBag)
    }
    
    /// selectedMap을 업데이트하고 현재 선택된 맵의 이름과 top3 랭킹을 리턴
    func mapSelected(_ selectedMap: Map) -> Single<(String, [Record])> {
        self.selectedMap = selectedMap
        return fetchMapRanking(mapID: selectedMap.mapID)
            .map { (selectedMap.name, $0) }
    }
    
    func getMapsInUpdatedRegion(region: MapRegion) -> [Map] {
        let northWestCorner = Coordinate(latitude: region.center.latitude-(region.span.latitudeDelta / 2.0),
                                         longitude: region.center.longitude-(region.span.longitudeDelta / 2.0))
        let southEastCorner = Coordinate(latitude: region.center.latitude+(region.span.latitudeDelta / 2.0),
                                         longitude: region.center.longitude+(region.span.longitudeDelta / 2.0))

        let mapsToDisplay = maps.filter { !self.visbleMapsIdx.contains($0.mapID) }
            .filter { map in
                let first = map.coordinates.first { coordinate in
                    (northWestCorner.latitude...southEastCorner.latitude).contains(coordinate.latitude) &&
                    (northWestCorner.longitude...southEastCorner.longitude).contains(coordinate.longitude)
                }
                return first != nil
            }
        visbleMapsIdx.append(contentsOf: mapsToDisplay.map { $0.mapID })
        return mapsToDisplay
    }
    
    func isStartable() -> Bool {
        guard let userLocation = try? userLocation.value(),
              let selectedMap,
              let minDistance = selectedMap.coordinates.map({ userLocation.distance(from: $0) }).min()
        else { return false }
        return minDistance <= 10
    }
    
    private func fetchMapRanking(mapID: Int) -> Single<[Record]> {
        recordRepository.fetchAllRecords()
            .map { records in
                var completedRecords = records.filter { $0.mapID == mapID && $0.isCompleted }

                // record 없을 경우 예외 처리
                completedRecords.append(contentsOf: [Record(id: -1),
                                            Record(id: -2),
                                            Record(id: -3)])
                
                let rankings = Array(completedRecords.sorted { $0.time < $1.time }.prefix(3))
                return rankings
            }
    }
}
