//
//  DefaultRecordMapViewUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/11/22.
//

import Foundation
import Firebase
import RxSwift

final class DefaultRecordMapViewUseCase: RecordMapViewUseCase {
    private let ref: DatabaseReference!
    private let repository: RecordRepository
    private let disposeBag = DisposeBag()
    
    var recordData = BehaviorSubject<[Int: RecordViewRecord]>(value: [:])
    var dropDownMenus = BehaviorSubject<[Map]>(value: [])
    var mapNameAndReocrds = BehaviorSubject<(String, [RecordViewRecord])>(value: ("", []))
    
    init(repository: RecordRepository) {
        ref = Database.database().reference()
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
    
    func loadRecordData() -> Observable<[RecordViewRecord]> {
        return Observable.create { emitter in
            self.repository.fetchRecordData()
                .subscribe(onNext: { records in
                    emitter.onNext(records)
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func fetchRecordDataAtIndex() -> Observable<[Int: RecordViewRecord]> {
        self.loadRecordData()
            .flatMap { records -> Observable<[Int: RecordViewRecord]> in
                var recordData = [Int: RecordViewRecord]()
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
                    if mapDataAtCategory[$0.location] != nil {
                        mapDataAtCategory[$0.location]?.append($0)
                    } else {
                        mapDataAtCategory[$0.location] = [$0]
                    }
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
    
    func getRecordsAtindexes(indexes: [Int]) -> Observable<[RecordViewRecord]> {
        return Observable.create { emitter in
            self.fetchRecordDataAtIndex()
                .subscribe {
                    guard let recordAtIndex = $0.element else { return }
                    var records = recordAtIndex
                        .filter { indexes.contains($0.key) }
                        .map { $0.value }
                    records.sort { return $0.time < $1.time }
                    
                    emitter.onNext(records)
                }.disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
    
    func getMapNameAndRecordsAtCategory(category: String) {
        self.getMapArrayAtCategory(category: category)
            .subscribe {
                guard let maps = $0.element else { return }
                guard let recordIndex = maps[0].records else {
                    self.mapNameAndReocrds.onNext((maps[0].name, []))
                    return
                }
                
                self.getRecordsAtindexes(indexes: recordIndex)
                    .subscribe {
                        guard let records = $0.element else { return }
                        self.mapNameAndReocrds.onNext((maps[0].name, records))
                    }.disposed(by: self.disposeBag)
            }.disposed(by: self.disposeBag)
    }
    
    func getMapNameAndRecordsAtMapName(mapName: String) {
        self.getMapAtMapName(mapName: mapName)
            .subscribe {
                guard let map = $0.element,
                      let recordIndex = map.records else {
                    self.mapNameAndReocrds.onNext((mapName, []))
                    return
                }
                
                self.getRecordsAtindexes(indexes: recordIndex)
                    .subscribe {
                        guard let records = $0.element else { return }
                        self.mapNameAndReocrds.onNext((mapName, records))
                    }.disposed(by: self.disposeBag)
            }.disposed(by: self.disposeBag)
    }
}
