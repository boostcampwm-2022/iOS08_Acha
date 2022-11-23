//
//  RecordViewModel.swift
//  Acha
//
//  Created by 배남석 on 2022/11/15.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import Firebase

class RecordViewModel {
    private var ref: DatabaseReference!
    private let disposeBag = DisposeBag()
    
    var sortedSectionDays: [Dictionary<String, DayTotalRecord>.Element] = []
    var recordAtDays = [String: [Record]]()
    var weekDistance = [RecordViewChartData]()
    var isFinishFetched = PublishRelay<Bool>()
    var mapData = [Int: Map]()
    
    init() {
        self.ref = Database.database().reference()
    }
    
    func fetchAllData() {
        ref.child("mapList").observeSingleEvent(of: .value,
                                                with: { [weak self] snapshot in
            guard let snapData = snapshot.value as? [Any],
                  let data = try? JSONSerialization.data(withJSONObject: snapData),
                  let map = try? JSONDecoder().decode([Map].self, from: data)
            else { return }
            map.forEach {
                self?.mapData[$0.mapID] = $0
            }
        })
        
        ref.child("record").observeSingleEvent(of: .value,
                                                with: { [weak self] snapshot in
            guard let snapData = snapshot.value as? [Any],
                  let data = try? JSONSerialization.data(withJSONObject: snapData),
                  let records = try? JSONDecoder().decode([Record].self, from: data),
                  let self
            else { return }
            
            var sectionDays = [String: DayTotalRecord]()
            records.forEach { record in
                let stringDate = record.createdAt
                
                if sectionDays[stringDate] != nil {
                    sectionDays[stringDate]?.distance += record.distance
                    sectionDays[stringDate]?.calorie += record.calorie
                } else {
                    sectionDays[stringDate] = DayTotalRecord(distance: record.distance,
                                                            calorie: record.calorie)
                }
                
                let achaRecord = Record(mapID: record.mapID,
                                            userID: record.userID,
                                            calorie: record.calorie,
                                            distance: record.distance,
                                            time: record.time,
                                            isSingleMode: record.isSingleMode,
                                            isWin: record.isWin,
                                            createdAt: record.createdAt)
                
                if self.recordAtDays[stringDate] != nil {
                    self.recordAtDays[stringDate]?.append(achaRecord)
                } else {
                    self.recordAtDays[stringDate] = [achaRecord]
                }
            }
            self.sortSectionDays(sectionDays: sectionDays)
            
            let startDay = Date(timeIntervalSinceNow: -(86400 * 6))
            
            self.weekDistance = Array(repeating: RecordViewChartData(number: 0, distance: 0), count: 7)
            for index in 0...6 {
                let day = startDay.addingTimeInterval(Double(index) * 86400)
                let dayString = day.convertToStringFormat(format: "yyyy-MM-dd")
                self.weekDistance[index].number = Int(day.convertToStringFormat(format: "e"))!
                
                if let recordAtDay = sectionDays[dayString] {
                    self.weekDistance[index].distance = recordAtDay.distance
                }
            }
            self.isFinishFetched.accept(true)
        })
    }
    
    func sortSectionDays(sectionDays: [String: DayTotalRecord]) {
        self.sortedSectionDays = sectionDays.sorted { sectionDayA, sectionDayB in
            let aCreateAt = sectionDayA.key.components(separatedBy: "-").map { Int($0)! }
            let bCreateAt = sectionDayB.key.components(separatedBy: "-").map { Int($0)! }
            
            if aCreateAt[0] == bCreateAt[0] {
                if aCreateAt[1] == bCreateAt[1] {
                    return aCreateAt[2] > bCreateAt[2]
                }
                return aCreateAt[1] > bCreateAt[1]
            }
            return aCreateAt[0] > bCreateAt[0]
        }
    }
    
    func searchMapName(mapId: Int) -> String {
        guard let mapData = self.mapData[mapId] else { return "" }
        let mapName = mapData.name
        return mapName
    }
}
