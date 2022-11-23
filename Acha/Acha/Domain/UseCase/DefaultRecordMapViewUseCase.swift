//
//  DefaultRecordMapViewUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/11/22.
//

import Foundation
import Firebase
import RxSwift

final class DefaultRecordMapViewUseCase {
    var ref: DatabaseReference!
    var mapDataAtCategory = PublishSubject<[String: [Map]]>()
    var mapDataAtMapName = PublishSubject<[String: Map]>()
    var recordData = PublishSubject<[Int: RecordViewRecord]>()
    
    init() {
        ref = Database.database().reference()
    }
    
    func fetchAllData() {
        fetchRecordData()
        fetchMapData()
    }
    
    func fetchMapData() {
        ref.child("mapList").observeSingleEvent(of: .value,
                                                with: { [weak self] snapshot in
            guard let snapData = snapshot.value as? [Any],
                  let data = try? JSONSerialization.data(withJSONObject: snapData),
                  let map = try? JSONDecoder().decode([Map].self, from: data),
                  let self
            else { return }
            
            var mapDataAtCategory = [String: [Map]]()
            var mapDataAtMapName = [String: Map]()
            map.forEach {
                if mapDataAtCategory[$0.location] != nil {
                    mapDataAtCategory[$0.location]?.append($0)
                } else {
                    mapDataAtCategory[$0.location] = [$0]
                }
                
                mapDataAtMapName[$0.name] = $0
            }
            self.mapDataAtMapName.onNext(mapDataAtMapName)
            self.mapDataAtCategory.onNext(mapDataAtCategory)
        })
    }
    
    func fetchRecordData() {
        ref.child("record").observeSingleEvent(of: .value,
                                                with: { [weak self] snapshot in
            guard let snapData = snapshot.value as? [Any],
                  let data = try? JSONSerialization.data(withJSONObject: snapData),
                  let records = try? JSONDecoder().decode([RecordViewRecord].self, from: data),
                  let self
            else { return }
            var recordData = [Int: RecordViewRecord]()
            records.forEach {
                recordData[$0.id] = $0
            }
            self.recordData.onNext(recordData)
        })
    }
}
