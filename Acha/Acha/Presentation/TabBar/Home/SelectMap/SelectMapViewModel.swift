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
    var mapCoordinates = PublishRelay<[Map]>()
    
    init() {
        self.ref = Database.database().reference()
    }
    
    func fetchAllMaps() {
        ref.child("mapList").observeSingleEvent(of: .value,
                                                with: { [weak self] snapshot in
            guard let snapData = snapshot.value as? [Any],
                  let data = try? JSONSerialization.data(withJSONObject: snapData),
                  let maps = try? JSONDecoder().decode([Map].self, from: data)
            else {
                print(Errors.decodeError)
                return
            }
            self?.mapCoordinates.accept(maps)
        })
    }
}
