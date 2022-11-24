//
//  SelectMapViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/14.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa

class SelectMapViewModel: BaseViewModel {
    
    // MARK: - Input
    struct Input {
        var viewWillAppearEvent: Observable<Void>
        var mapSelected = PublishSubject<Map>()
        var regionDidChanged: PublishSubject<MapRegion>
        var startButtonTapped: Observable<Void>
        var backButtonTapped: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        var visibleMaps = PublishRelay<[Map]>()
        var cannotStart = PublishRelay<Void>()
        var selectedMapRankings = PublishRelay<(String, [Record])>()    // map name, ranking
    }
    private var maps: [Map]
    private var visbleMapsIdx: [Int]
    var rankings: [Int: [Record]]
    var selectedMap: Map?
    var userLocation: Coordinate?
    
    // MARK: - Properties
    private var ref: DatabaseReference!
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewWillAppearEvent
            .subscribe(onNext: { [weak self] _ in
                self?.fetchAllMaps()
            })
            .disposed(by: disposeBag)
        
        input.startButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self,
                      let map = self.selectedMap else { return }
                if self.checkStartable(mapCoordinates: map.coordinates) {
                    self.coordinator.showSingleGamePlayViewController(selectedMap: map)
                } else {
                    output.cannotStart.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator.delegate?.didFinished(childCoordinator: self.coordinator)
            })
            .disposed(by: disposeBag)
        
        input.regionDidChanged
            .subscribe(onNext: { [weak self] region in
                guard let self else { return }
                let mapsToDisplay = self.getMapsInUpdatedRegion(region: region)
                self.visbleMapsIdx.append(contentsOf: mapsToDisplay.map { $0.mapID })
                output.visibleMaps.accept(mapsToDisplay)
            })
            .disposed(by: disposeBag)
        
        input.mapSelected
            .subscribe(onNext: { [weak self] selectedMap in
                guard let self else { return }
                self.selectedMap = selectedMap
                self.fetchMapRecord(mapID: selectedMap.mapID)
                    .asObservable()
                    .map { (selectedMap.name, $0) }
                    .bind(to: output.selectedMapRankings)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    
        return output
    }
    
    // MARK: - Dependency
    var coordinator: SingleGameCoordinator
    
    // MARK: - Lifecycles
    init(coordinator: SingleGameCoordinator) {
        self.ref = Database.database().reference()
        self.coordinator = coordinator
        self.maps = []
        self.rankings = [:]
        self.visbleMapsIdx = []
    }
    
    // MARK: - Helpers
    func fetchAllMaps() {
        self.ref.child("mapList").observeSingleEvent(of: .value,
                                                with: { [weak self] snapshot in
            guard let snapData = snapshot.value as? [Any],
                  let data = try? JSONSerialization.data(withJSONObject: snapData),
                  let mapDatas = try? JSONDecoder().decode([Map].self, from: data)
            else {
                print(Errors.decodeError)
                return
            }
            self?.maps = mapDatas
        })
    }
    
    func fetchMapRecord(mapID: Int) -> Single<[Record]> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            self.ref.child("record").observeSingleEvent(of: .value,
                                                   with: { snapshot in
                guard let snapData = snapshot.value as? [Any],
                      let data = try? JSONSerialization.data(withJSONObject: snapData),
                      var records = try? JSONDecoder().decode([Record].self, from: data)
                else {
                    print(Errors.decodeError)
                    return
                }

                records.append(contentsOf: [Record(id: -1, mapID: mapID),
                                            Record(id: -2, mapID: mapID),
                                            Record(id: -3, mapID: mapID)])
                let rankings = Array(
                    records.filter { $0.mapID == mapID }
                    .sorted { $0.time < $1.time }
                    .prefix(3)
                )
                return single(.success(rankings))
            })
            return Disposables.create()
        }
    }
    
    private func checkStartable(mapCoordinates: [Coordinate]) -> Bool {
        guard let userLocation = self.userLocation,
              let minDistance = mapCoordinates.map({ userLocation.distance(from: $0) }).min()
        else { return false }
        return !(minDistance > 10)
    }
    
    private func getMapsInUpdatedRegion(region: MapRegion) -> [Map] {
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
        return mapsToDisplay
    }
}
