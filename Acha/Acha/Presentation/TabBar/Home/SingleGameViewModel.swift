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
    var mapCoordinates = PublishRelay<Map>()
    var ref: DatabaseReference!
    
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
        })
    }
}
