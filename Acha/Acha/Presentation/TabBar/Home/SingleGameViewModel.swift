//
//  SingleGameViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/15.
//

import Foundation
import RxRelay
import Firebase

final class SingleGameViewModel {
    let map: Map
    var ref: DatabaseReference!
    var mapCoordinates = PublishRelay<Map>()
    var coordinates: [Coordinate] = []
    var route = [Coordinate]()
    let movedDistance = BehaviorRelay<Double>(value: 0.0)
    let visitedCoordinate = BehaviorRelay<(now: Coordinate?, previous: Coordinate?)>(value: (nil, nil))
    let time = BehaviorRelay<Int>(value: 0)
    
    init(map: Map) {
        self.map = map
        self.ref = Database.database().reference()
    }
    
    func fetchAllMaps() {
        ref.child("mapList").observeSingleEvent(of: .value,
                                                with: { [weak self] snapshot in
            guard let snapData = snapshot.value as? [Any],
                  let data = try? JSONSerialization.data(withJSONObject: snapData),
                  let maps = try? JSONDecoder().decode([Map].self, from: data)
            else {
                print("에러")
                return
            }
            self?.mapCoordinates.accept(maps.last!)
            self?.coordinates = maps.last!.coordinates
        })
    }
    
    func userMoved(coordinate here: Coordinate, distance: Double) {
        route.append(here)
        
        let newDistance = distance + movedDistance.value
        self.movedDistance.accept(newDistance)
        
        guard let nearestCoordinate = coordinates.min(by: {
            self.meterDistance(from: $0, here: here) < self.meterDistance(from: $1, here: here)
        }) else { print("why"); return }
        
        let nearestDistance = meterDistance(from: nearestCoordinate, here: here)
        
        if nearestDistance < 0.5 {
            let before = visitedCoordinate.value
            
            if before.now == nil {
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
