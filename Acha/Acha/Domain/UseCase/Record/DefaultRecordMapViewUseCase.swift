//
//  DefaultRecordMapViewUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/11/22.
//

import Foundation
import RxSwift

final class DefaultRecordMapViewUseCase: RecordMapViewUseCase {
    private let recordRepository: RecordRepository
    private let mapRepository: MapRepository
    private let disposeBag = DisposeBag()
    
    var dropDownMenus = BehaviorSubject<[Map]>(value: [])
    var mapDataAtMapName = BehaviorSubject<[String: Map]>(value: [:])
    var mapDataAtCategory = BehaviorSubject<[String: [Map]]>(value: [:])
    var mapNameAndRecordDatas = PublishSubject<(mapImage: Data?,
                                                mapName: String,
                                                recordDatas: [Record])>()
    
    init(recordRepository: RecordRepository, mapRepository: MapRepository) {
        self.recordRepository = recordRepository
        self.mapRepository = mapRepository
    }
    
    func loadMapData() {
        mapRepository.fetchAllMaps()
            .asObservable()
            .subscribe(onNext: { maps in
                var mapDataAtCategory = [String: [Map]]()
                var mapDataAtMapName = [String: Map]()
                maps.forEach {
                    mapDataAtCategory[$0.location] = (mapDataAtCategory[$0.location] ?? []) + [$0]
                    mapDataAtMapName[$0.name] = $0
                }
                self.mapDataAtMapName.onNext(mapDataAtMapName)
                self.mapDataAtCategory.onNext(mapDataAtCategory)
            }).disposed(by: self.disposeBag)
    }
    
    func loadRecordData() -> Observable<[Record]> {
        recordRepository.fetchAllRecords()
            .asObservable()
    }
    
    func getDropDownMenus(mapName: String) {
        guard let mapDataAtMapName = try? mapDataAtMapName.value(),
              let mapData = mapDataAtMapName[mapName],
              let mapDatasAtCategory = try? mapDataAtCategory.value(),
              let mapDatas = mapDatasAtCategory[mapData.location] else { return }
        
        self.dropDownMenus.onNext(mapDatas)
    }
    
    func getMapNameAndRecordsAtLocation(location: String) {
        mapRepository.fetchMapsAtLocation(location: location)
            .subscribe(onNext: { [weak self] maps in
                guard let self else { return }
                if maps.isEmpty {
                    self.mapNameAndRecordDatas.onNext((mapImage: nil, mapName: "맵이 없습니다.", recordDatas: []))
                } else {
                    let map = maps.sorted { $0.mapID < $1.mapID }[0]
                    self.recordRepository.fetchRecordDataAtMapID(mapID: map.mapID)
                        .subscribe(onSuccess: { records in
                            let records = records.filter { $0.isCompleted == true }.sorted { $0.time < $1.time }
                            self.mapNameAndRecordDatas.onNext((mapImage: map.image,
                                                               mapName: map.name,
                                                               recordDatas: records))
                        }, onFailure: { _ in
                            self.mapNameAndRecordDatas.onNext((mapImage: map.image,
                                                               mapName: map.name,
                                                               recordDatas: []))
                        })
                        .disposed(by: self.disposeBag)
                }
            }, onError: { [weak self] _ in
                guard let self else { return }
                self.mapNameAndRecordDatas.onNext((mapImage: nil, mapName: "맵이 없습니다.", recordDatas: []))
            })
            .disposed(by: disposeBag)
    }
    
    func getMapNameAndRecordDatasAtMapName(mapName: String) {
        loadRecordData()
            .subscribe { recordDatas in
                guard let mapDataAtMapName = try? self.mapDataAtMapName.value(),
                      let mapData = mapDataAtMapName[mapName],
                      let recordDatas = recordDatas.element else { return }
                
                let recordDatasAtMapId = recordDatas
                    .filter { $0.mapID == mapData.mapID && $0.isCompleted == true }
                    .sorted { $0.time < $1.time }
                
                self.mapNameAndRecordDatas.onNext((mapImage: mapData.image,
                                                   mapName: mapData.name,
                                                   recordDatas: recordDatasAtMapId))
            }.disposed(by: self.disposeBag)
    }
}
