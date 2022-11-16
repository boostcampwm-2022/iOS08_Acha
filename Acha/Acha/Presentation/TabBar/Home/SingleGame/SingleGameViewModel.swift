//
//  SingleGameViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/15.
//

import Foundation
import RxRelay

final class SingleGameViewModel {
    private let coordinator: Coordinator
    
    let map: Map
    var route = [Coordinate]()
    let movedDistance = BehaviorRelay<Double>(value: 0.0)
    let visitedCoordinate = BehaviorRelay<(previous: Coordinate?, now: Coordinate?)>(value: (nil, nil))
    let time = BehaviorRelay<Int>(value: 0)
    
    init(coordinator: Coordinator, map: Map) {
        self.map = map
        self.coordinator = coordinator
    }
    
    func userMoved(coordinate here: Coordinate, distance: Double) {
        route.append(here)
        
        let newDistance = distance + movedDistance.value
        self.movedDistance.accept(newDistance)
        
        guard let nearestCoordinate = map.coordinates.min(by: {
            self.meterDistance(from: $0, here: here) < self.meterDistance(from: $1, here: here)
        }) else { return }
        
        let nearestDistance = meterDistance(from: nearestCoordinate, here: here)
        
        print(Int(nearestDistance))
        if nearestDistance < 0.5 {
            let before = visitedCoordinate.value
            
            if before.previous == nil {
                visitedCoordinate.accept((nearestCoordinate, nil))
            } else {
                visitedCoordinate.accept((nearestCoordinate, visitedCoordinate.value.previous))
            }
            
        } else if nearestDistance > 10 {
            #warning("todo: alert")
        }
    }
    
    func meterDistance(from: Coordinate, here: Coordinate) -> Double {
        let theta = from.longitude - here.longitude
        let dist = sin(from.latitude.deg2rad()) *
        sin(here.latitude.deg2rad()) +
        cos(from.latitude.deg2rad()) *
        cos(here.latitude.deg2rad()) *
        cos(theta.deg2rad())
        
        return acos(dist).rad2deg() * 60 * 1.853159616 / 1000
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            self.time.accept(self.time.value + 1)
        })
    }
}
