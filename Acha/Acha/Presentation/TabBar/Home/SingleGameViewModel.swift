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
    let visitedCoordinate = BehaviorRelay<(Coordinate?, Coordinate?)>(value: (nil, nil))
    
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
            self?.mapCoordinates.accept(maps.first!)
            self?.coordinates = maps.first!.coordinates
        })
    }
    
    func userMoved(coordinate here: Coordinate, distance: Double) {
        route.append(here)
        
        let newDistance = distance + movedDistance.value
        self.movedDistance.accept(newDistance)
        
//        let nearest = map.coordinates.map { self.distance(from: $0, here: here) }.min()
        if coordinates.count == 0 {
            print("00")
            return
        }
        print(self.meterDistance(from: coordinates.first!, here: here))
        guard let nearestCoordinate = coordinates.min(by: {
            self.meterDistance(from: $0, here: here) < self.meterDistance(from: $1, here: here)
        }) else { print("why"); return }
        
        let nearestDistance = meterDistance(from: nearestCoordinate, here: here)
        
        if nearestDistance < 0.5 {
            let before = visitedCoordinate.value
            print("near")
            if before.0 == nil {
                visitedCoordinate.accept((nearestCoordinate, nil))
            } else {
                visitedCoordinate.accept((nearestCoordinate, visitedCoordinate.value.0))
            }
            print(visitedCoordinate.value, "hi")
        } else if nearestDistance > 10 {
            #warning("todo: alert")
        }
    }
    
    func meterDistance(from: Coordinate, here: Coordinate) -> Double {
        let theta = from.longitude - here.longitude
        let dist = sin(deg2rad(from.latitude)) *
        sin(deg2rad(here.latitude)) +
        cos(deg2rad(from.latitude)) *
        cos(deg2rad(here.latitude)) *
        cos(deg2rad(theta))
        
        return rad2deg(acos(dist)) * 60 * 1.853159616 / 1000
    }
    
    private func deg2rad(_ degree: Double) -> Double {
        return degree * .pi / 180
     }
    
    private func rad2deg(_ radian: Double) -> Double {
        return radian * 180.0 / .pi
     }

}
