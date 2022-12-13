//
//  DefaultRecordViewUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/11/21.
//

import Foundation
import RxSwift

final class DefaultRecordMainViewUseCase: RecordMainViewUseCase {
    private let userRepository: UserRepository
    private let recordRepository: RecordRepository
    private let mapRepository: MapRepository
    private let disposeBag = DisposeBag()
    
    var mapNameAtMapId = BehaviorSubject<[Int: String]>(value: [:])
    var weekDatas = PublishSubject<[RecordViewChartData]>()
    var recordSectionDatas = PublishSubject<(allDates: [String],
                                             totalRecordAtDate: [String: DayTotalRecord],
                                             recordsAtDate: [String: [Record]],
                                             mapNameAtMapId: [Int: String])>()
    
    init(userRepository: UserRepository,
         recordRepository: RecordRepository,
         mapRepository: MapRepository) {
        self.userRepository = userRepository
        self.recordRepository = recordRepository
        self.mapRepository = mapRepository
    }
    
    func loadMapData() {
        self.mapRepository.fetchAllMaps()
            .subscribe { maps in
                var mapNameAtMapId = [Int: String]()
                maps.forEach {
                    mapNameAtMapId[$0.mapID] = $0.name
                }
                self.mapNameAtMapId.onNext(mapNameAtMapId)
            }.disposed(by: self.disposeBag)
    }
    
    func loadRecordData() {
        userRepository.fetchUserData()
            .subscribe(onSuccess: { [weak self] user in
                guard let self else { return }
                self.recordRepository.fetchAllRecords()
                    .map { $0.filter { user.records.contains($0.id) } }
                    .subscribe(onSuccess: { [weak self] userRecords in
                        guard let self,
                              let mapNameAtMapId = try? self.mapNameAtMapId.value() else { return }
                        var totalDataAtDate = [String: DayTotalRecord]()
                        var allDates = [String]()
                        var recordsAtDate = [String: [Record]]()
                        
                        userRecords.forEach {
                            recordsAtDate[$0.createdAt] = (recordsAtDate[$0.createdAt] ?? []) + [$0]
                            
                            if !allDates.contains($0.createdAt) {
                                allDates.append($0.createdAt)
                            }
                            
                            if totalDataAtDate[$0.createdAt] != nil {
                                totalDataAtDate[$0.createdAt]?.distance += $0.distance
                                totalDataAtDate[$0.createdAt]?.calorie += $0.calorie
                            } else {
                                totalDataAtDate[$0.createdAt] = DayTotalRecord(distance: $0.distance,
                                                                              calorie: $0.calorie)
                            }
                        }
                        
                        allDates.sort {
                            return $0.convertToDateFormat(format: "yyyy-MM-dd") > $1.convertToDateFormat(format: "yyyy-MM-dd")
                        }
                        
                        let startDay = Date(timeIntervalSinceNow: -(86400 * 6))
                        var weekDatas = Array(repeating: RecordViewChartData(number: 0, distance: 0), count: 7)
                        
                        for index in 0...6 {
                            let day = startDay.addingTimeInterval(Double(index) * 86400)
                            let dayString = day.convertToStringFormat(format: "yyyy-MM-dd")
                            guard let weekDayIndex = Int(day.convertToStringFormat(format: "e")) else { return }
                            weekDatas[index].number = weekDayIndex
                            
                            if let totalData = totalDataAtDate[dayString] {
                                weekDatas[index].distance = totalData.distance
                            }
                        }
                        self.weekDatas.onNext(weekDatas)
                        self.recordSectionDatas.onNext((allDates: allDates,
                                                        totalRecordAtDate: totalDataAtDate,
                                                        recordsAtDate: recordsAtDate,
                                                        mapNameAtMapId: mapNameAtMapId))
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }
}
