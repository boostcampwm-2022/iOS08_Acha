//
//  SelectMapViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/14.
//

import Foundation
import Firebase
import RxSwift
import RxRelay

class SelectMapViewModel {
    var ref: DatabaseReference!
    var selectedLocationCoordinates = PublishRelay<[(Double, Double)]>()
    init() {
        self.ref = Database.database().reference()
    }
    
    func getCoordinates(mapID: String) {
        ref.child("mapList/\(mapID)/coordinates")
            .observeSingleEvent(
                of: .value,
                with: { [self] snapshot in
                    let decoder = JSONDecoder()
                    guard let snapData = snapshot.value as? [Any],
                          let data = try? JSONSerialization.data(withJSONObject: snapData),
                          let dictCoordinates = try? decoder.decode([[String:Double]].self, from: data)
                    else {
                        print("hi")
                        return
                    }
                    let coordinates = dictCoordinates.compactMap { location in
                        guard let latitude = location["latitude"],
                              let longitude = location["longitude"] else { return (0.0, 0.0) }
                        return (latitude, longitude)
                    }
                    selectedLocationCoordinates.accept(coordinates)
                })
    }
}
