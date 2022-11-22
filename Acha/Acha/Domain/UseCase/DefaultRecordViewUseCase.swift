//
//  DefaultRecordViewUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/11/21.
//

import Foundation
import Firebase
import RxSwift

final class DefaultRecordViewUseCase: RecordViewUseCase {
    var ref: DatabaseReference!
    var mapData = PublishSubject<[Int: Map]>()
    var days = PublishSubject<[String]>()
    var sectionDays = PublishSubject<[String: DayTotalRecord]>()
    var recordAtDays = PublishSubject<[String: [RecordViewRecord]]>()
    var weekDistances = PublishSubject<[RecordViewChartData]>()
    
    init() {
        ref = Database.database().reference()
    }
    
    func fetchAllData() {
        fetchMapData()
        fetchRecordData()
    }
    
    func fetchMapData() {
        ref.child("mapList").observeSingleEvent(of: .value,
                                                with: { [weak self] snapshot in
            guard let snapData = snapshot.value as? [Any],
                  let data = try? JSONSerialization.data(withJSONObject: snapData),
                  let map = try? JSONDecoder().decode([Map].self, from: data)
            else { return }
            
            var mapData = [Int: Map]()
            map.forEach {
                mapData[$0.mapID] = $0
            }
            self?.mapData.onNext(mapData)
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
            
            var days: [String] = []
            var sectionDays: [String: DayTotalRecord] = [:]
            var recordAtDays: [String: [RecordViewRecord]] = [:]
            records.forEach { record in
                let stringDate = record.createdAt
                if !days.contains(stringDate) {
                    days.append(stringDate)
                }
                
                if sectionDays[stringDate] != nil {
                    sectionDays[stringDate]?.distance += record.distance
                    sectionDays[stringDate]?.calorie += record.calorie
                } else {
                    sectionDays[stringDate] = DayTotalRecord(distance: record.distance,
                                                            calorie: record.calorie)
                }
                
                let achaRecord = RecordViewRecord(mapID: record.mapID,
                                            userID: record.userID,
                                            calorie: record.calorie,
                                            distance: record.distance,
                                            time: record.time,
                                            isSingleMode: record.isSingleMode,
                                            isWin: record.isWin,
                                            createdAt: record.createdAt)
                
                if recordAtDays[stringDate] != nil {
                    recordAtDays[stringDate]?.append(achaRecord)
                } else {
                    recordAtDays[stringDate] = [achaRecord]
                }
            }
            self.sectionDays.onNext(sectionDays)
            self.days.onNext(self.sortDays(days: days))
            self.recordAtDays.onNext(recordAtDays)
            
            let startDay = Date(timeIntervalSinceNow: -(86400 * 6))
            
            var weekDistances = Array(repeating: RecordViewChartData(number: 0, distance: 0), count: 7)
            for index in 0...6 {
                let day = startDay.addingTimeInterval(Double(index) * 86400)
                let dayString = day.convertToStringFormat(format: "yyyy-MM-dd")
                weekDistances[index].number = Int(day.convertToStringFormat(format: "e"))!
                
                if let recordAtDay = sectionDays[dayString] {
                    weekDistances[index].distance = recordAtDay.distance
                }
            }
            self.weekDistances.onNext(weekDistances)
//            self.isFinishFetched.accept(true)
        })
    }
    
    private func sortDays(days: [String]) -> [String] {
        return days.sorted { first, second in
            let firstCreateAt = first.components(separatedBy: "-").map { Int($0)! }
            let secondCreateAt = second.components(separatedBy: "-").map { Int($0)! }
            
            if firstCreateAt[0] == secondCreateAt[0] {
                if firstCreateAt[1] == secondCreateAt[1] {
                    return firstCreateAt[2] > secondCreateAt[2]
                }
                return firstCreateAt[1] > secondCreateAt[1]
            }
            return firstCreateAt[0] > secondCreateAt[0]
        }
    }
}
