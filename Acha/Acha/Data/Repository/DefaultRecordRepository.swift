//
//  DefaultRecordRepository.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/27.
//

import RxSwift

final class DefaultRecordRepository: RecordRepository {
    
    private let realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService
    private let healthKitService: HealthKitService
    private let disposeBag = DisposeBag()
    
    init(realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService,
         healthKitService: HealthKitService
    ) {
        self.realTimeDatabaseNetworkService = realTimeDatabaseNetworkService
        self.healthKitService = healthKitService
    }
    
    func fetchAllRecords() -> Single<[Record]> {
        realTimeDatabaseNetworkService.fetch(type: FirebaseRealtimeType.record(id: nil))
            .map { (recordDTOs: [RecordDTO]) in
                return recordDTOs.map { $0.toDomain() }
            }
    }
    
    func uploadNewRecord(record: Record) {
        realTimeDatabaseNetworkService.fetch(type: FirebaseRealtimeType.record(id: nil))
            .map { (recordDTOs: [RecordDTO]) in
                return recordDTOs.map { $0.toDomain() }
            }.subscribe(onSuccess: { [weak self] records in
                guard let self else { return }
                var record = record
                record.id = records.count
                self.realTimeDatabaseNetworkService.uploadNewRecord(index: records.count, data: record)
            })
    }
    
    func healthKitAuthorization() -> Observable<Void> {
        return healthKitService.authorization()
    }
    
    func healthKitWrite(_ data: HealthKitWriteData) -> Observable<Void> {
        return Observable<Void>.zip(
            healthKitService.write(type: .distances(meter: data.distance, time: data.diatanceTime)),
            healthKitService.write(type: .calories(kcal: data.calorie, time: data.calorieTime))
        ) { _, _ in return }
        .asObservable()
    }
    
    func healthKitRead() -> Observable<HealthKitReadData> {
        return Observable<HealthKitReadData>.combineLatest(
            healthKitService.read(type: .calorie),
            healthKitService.read(type: .distance)
        ) { calorie, distance in
            return HealthKitReadData(
                calorie: calorie,
                distance: distance
            )
        }
    }
}
