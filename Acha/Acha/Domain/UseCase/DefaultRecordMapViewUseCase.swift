//
//  DefaultRecordMapViewUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/11/22.
//

import Foundation
import RxSwift

final class DefaultRecordMapViewUseCase: RecordMapViewUseCase {
    private let repository: RecordRepository
    private let disposeBag = DisposeBag()
    
    var recordData = BehaviorSubject<[Int: Record]>(value: [:])
    var dropDownMenus = BehaviorSubject<[Map]>(value: [])
    var mapNameAndRecords = BehaviorSubject<(String, [Record])>(value: ("", []))
    
    init(repository: RecordRepository) {
        self.repository = repository
    }
    
    func loadMapData() -> Observable<[Map]> {
        return Observable.create { emitter in
            self.repository.fetchMapData()
                .subscribe { maps in
                    emitter.onNext(maps)
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func loadRecordData() -> Observable<[Record]> {
        return Observable.create { emitter in
            self.repository.fetchRecordData()
                .subscribe(onNext: { records in
                    emitter.onNext(records)
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func fetchRecordDataAtIndex() -> Observable<[Int: Record]> {
        self.loadRecordData()
            .flatMap { records -> Observable<[Int: Record]> in
                var recordData = [Int: Record]()
                records.forEach {
                    recordData[$0.id] = $0
                }
                return Observable.create { emitter in
                    emitter.onNext(recordData)
                    
                    return Disposables.create()
                }
            }
    }
     
    func fetchMapDataAtMapName() -> Observable<[String: Map]> {
        self.loadMapData()
            .flatMap { maps -> Observable<[String: Map]> in
                var mapDataAtMapName = [String: Map]()
                maps.forEach {
                    mapDataAtMapName[$0.name] = $0
                }
                return Observable.create { emitter in
                    emitter.onNext(mapDataAtMapName)
                    
                    return Disposables.create()
                }
            }
    }
    
    func fetchMapDataAtCategory() -> Observable<[String: [Map]]> {
        self.loadMapData()
            .flatMap { maps -> Observable<[String: [Map]]> in
                var mapDataAtCategory = [String: [Map]]()
                maps.forEach {
                    mapDataAtCategory[$0.location] = (mapDataAtCategory[$0.location] ?? []) + [$0]
                }
                return Observable.create { emitter in
                    emitter.onNext(mapDataAtCategory)
                    
                    return Disposables.create()
                }
        }
    }
    
    func getMapArrayAtCategory(category: String) -> Observable<[Map]> {
        return Observable.create { emitter in
            self.fetchMapDataAtCategory()
                .subscribe { mapDataAtCategory in
                    guard let maps = mapDataAtCategory[category] else { return }
                    emitter.onNext(maps)
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func getMapAtMapName(mapName: String) -> Observable<Map> {
        return Observable.create { emitter in
            self.fetchMapDataAtMapName()
                .subscribe { mapDataAtMapName in
                    guard let map = mapDataAtMapName[mapName] else { return }
                    emitter.onNext(map)
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func getDropDownMenus(mapName: String) {
        self.getMapAtMapName(mapName: mapName)
            .subscribe {
                guard let map = $0.element else { return }
                self.getMapArrayAtCategory(category: map.location)
                    .subscribe {
                        guard let maps = $0.element else { return }
                        self.dropDownMenus.onNext(maps)
                    }.disposed(by: self.disposeBag)
            }.disposed(by: self.disposeBag)
    }
    
    func getRecordsAtIndexes(indexes: [Int]) -> Observable<[Record]> {
        return fetchRecordDataAtIndex()
            .map { recordAtIndex in
                let records = recordAtIndex
                    .filter { indexes.contains($0.key) }
                    .map { $0.value }
                    .sorted { $0.time < $1.time }
                return records
            }
    }
    
    func getMapNameAndRecordsAtCategory(category: String) {
        self.getMapArrayAtCategory(category: category)
            .subscribe {
                guard let maps = $0.element else { return }
                guard let recordIndex = maps[0].records else {
                    self.mapNameAndRecords.onNext((maps[0].name, []))
                    return
                }
                
                self.getRecordsAtIndexes(indexes: recordIndex)
                    .subscribe {
                        guard let records = $0.element else { return }
                        self.mapNameAndRecords.onNext((maps[0].name, records))
                    }.disposed(by: self.disposeBag)
            }.disposed(by: self.disposeBag)
    }
    
    func getMapNameAndRecordsAtMapName(mapName: String) {
        self.getMapAtMapName(mapName: mapName)
            .subscribe {
                guard let map = $0.element,
                      let recordIndex = map.records else {
                    self.mapNameAndRecords.onNext((mapName, []))
                    return
                }
                
                self.getRecordsAtIndexes(indexes: recordIndex)
                    .subscribe {
                        guard let records = $0.element else { return }
                        self.mapNameAndRecords.onNext((mapName, records))
                    }.disposed(by: self.disposeBag)
            }.disposed(by: self.disposeBag)
    }
}