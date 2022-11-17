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

struct DayData {
    var distance: Int
    var calorie: Int
}

class RecordViewModel {
    private var ref: DatabaseReference!
    private let disposeBag = DisposeBag()
    
    var sortedSetionDays: [Dictionary<String, DayData>.Element] = []
    var recordAtDays = [String: [AchaRecord]]()
    var weekDistance = [ChartData]()
    var isFinishFetched = PublishRelay<Bool>()
    
    init() {
        self.ref = Database.database().reference()
    }
    
    func fetchAllData() {
        ref.child("record").observeSingleEvent(of: .value,
                                                with: { [weak self] snapshot in
            guard let snapData = snapshot.value as? [Any],
                  let data = try? JSONSerialization.data(withJSONObject: snapData),
                  let records = try? JSONDecoder().decode([AchaRecord].self, from: data)
            else { return }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            var sectionDays = [String: DayData]()
            records.forEach { record in
                let stringDate = record.createdAt
                
                if sectionDays[stringDate] != nil {
                    sectionDays[stringDate]?.distance += record.distance
                    sectionDays[stringDate]?.calorie += record.calorie
                } else {
                    sectionDays[stringDate] = DayData(distance: record.distance,
                                                            calorie: record.calorie)
                }
                
                let achaRecord = AchaRecord(mapID: 0,
                                            userID: "",
                                            calorie: record.calorie,
                                            distance: record.distance,
                                            time: record.time,
                                            isSingleMode: record.isSingleMode,
                                            createdAt: record.createdAt)
                
                if self?.recordAtDays[stringDate] != nil {
                    self?.recordAtDays[stringDate]?.append(achaRecord)
                } else {
                    self?.recordAtDays[stringDate] = [achaRecord]
                }
            }
            self?.sortSectionDays(sectionDays: sectionDays)
            
            let startDay = Date(timeIntervalSinceNow: -(86400 * 6))
            
            let dayFormmater = DateFormatter()
            dayFormmater.dateFormat = "e"
            
            self?.weekDistance = Array(repeating: ChartData(number: 0, distance: 0), count: 7)
            for index in 0...6 {
                let day = startDay.addingTimeInterval(Double(index) * 86400)
                let dayString = dateFormatter.string(from: day)
                self?.weekDistance[index].number = Int(dayFormmater.string(from: day))!
                
                if let recordAtDay = sectionDays[dayString] {
                    self?.weekDistance[index].distance = recordAtDay.distance
                }
            }
            self?.isFinishFetched.accept(true)
        })
    }
    
    func sortSectionDays(sectionDays: [String: DayData]) {
        self.sortedSetionDays = sectionDays.sorted { dicA, dicB in
            let aCreateAt = dicA.key.components(separatedBy: "-").map { Int($0)! }
            let bCreateAt = dicB.key.components(separatedBy: "-").map { Int($0)! }
            
            if aCreateAt[0] == bCreateAt[0] {
                if aCreateAt[1] == bCreateAt[1] {
                    return aCreateAt[2] > bCreateAt[2]
                }
                return aCreateAt[1] > bCreateAt[1]
            }
            return aCreateAt[0] > bCreateAt[0]
        }
    }
}
