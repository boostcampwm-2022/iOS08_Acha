//
//  DefaultHealthKitService.swift
//  Acha
//
//  Created by hong on 2022/11/30.
//

import Foundation
import HealthKit
import RxSwift

struct DefaultHealthKitService: HealthKitService {
    
    private let healthStore = HKHealthStore()
    
    enum DefaultHealthKitServiceError: Error {
        case noAuthorization
        case requestAuthorizationError
        case convertError
        case writeError
        case loadError
    }
    
    private let disposeBag = DisposeBag()
    
    public func authorization() -> Observable<Void> {
        
        let readTypes = Set([
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        ])
        
        let writeTypes = Set([
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ])
        
        return Observable<Void>.create { observer in

            healthStore.requestAuthorization(
                toShare: readTypes,
                read: writeTypes
            ) { _, error in
                if error != nil {
                    observer.onError(DefaultHealthKitServiceError.requestAuthorizationError)
                } else {
                    observer.onNext(())
                }
            }
            return Disposables.create()
        }
    }
    
    public func write(type: DefaultHealthKitServiceType) -> Observable<Void> {
        
        return Observable<Void>.create { observer in
            let data = hkQuantitySampleData(type: type)
            HKHealthStore().save(data) { result, error in
                if error != nil, !result {
                    observer.onError(DefaultHealthKitServiceError.writeError)
                } else {
                    observer.onNext(())
                }
            }
            return Disposables.create()
        }

    }
    
    public func read(type: DefaultHealthKitServiceType) -> Observable<Double> {
        let sampleType: HKQuantityType = hkQuantityType(type: type)
        let mostRecentPredicate = HKQuery.predicateForSamples(
            withStart: Date.distantPast,
            end: Date(),
            options: []
        )
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )
        let limit = 1
        
        return Observable<Double>.create { observer in
            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: mostRecentPredicate,
                limit: limit,
                sortDescriptors: [sortDescriptor]
            ) { (_, samples, error) in
                guard error == nil,
                      let samples = samples,
                      let mostRecentSample = samples.first as? HKQuantitySample
                else {
                    observer.onError(DefaultHealthKitServiceError.loadError)
                    return
                }
                let value = mostRecentSample.quantity.doubleValue(for: hkUnitType(type: type))
                observer.onNext(value)
            }
            healthStore.execute(query)
            return Disposables.create()
        }
    }
    
    private func hkQuantityType(type: DefaultHealthKitServiceType) -> HKQuantityType {
        let sampleType: HKQuantityType
        switch type {
        case .step, .steps:
            sampleType = .quantityType(forIdentifier: .stepCount)!
        case .distance, .distances:
            sampleType = .quantityType(forIdentifier: .distanceWalkingRunning)!
        case .calorie, .calories:
            sampleType = .quantityType(forIdentifier: .activeEnergyBurned)!
        }
        return sampleType
    }
    
    private func hkUnitType(type: DefaultHealthKitServiceType) -> HKUnit {
        let sampleType: HKUnit
        switch type {
        case .step, .steps:
            sampleType = .count()
        case .distance, .distances:
            sampleType = .meter()
        case .calorie, .calories:
            sampleType = .kilocalorie()
        }
        return sampleType
    }
    
    private func hkQuantitySampleData(type: DefaultHealthKitServiceType) -> HKQuantitySample {
        let quantityType: HKQuantityType = hkQuantityType(type: type)
        let unit: HKUnit = hkUnitType(type: type)
        
        let quantity = HKQuantity(unit: unit, doubleValue: Double(type.value))
        let oldDate = Date().since(type.time)
        return HKQuantitySample(
            type: quantityType,
            quantity: quantity,
            start: oldDate,
            end: Date()
        )
    }
    
    public func haveAuthorization() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
}

enum DefaultHealthKitServiceType {
    case steps(step: Int, time: Int64)
    case distances(meter: Int, time: Int64)
    case calories(kcal: Int, time: Int64)
    case step, distance, calorie
    
    var value: Int {
        switch self {
        case .calories(let value, _):
            return value
        case .distances(let value, _):
            return value
        case .steps(let value, _):
            return value
        default:
            return 0
        }
    }

    var time: Int64 {
        switch self {
        case .steps(_, time: let time):
            return time
        case .distances(_, time: let time):
            return time
        case .calories(_, time: let time):
            return time
        default:
            return 0
        }
    }
}
