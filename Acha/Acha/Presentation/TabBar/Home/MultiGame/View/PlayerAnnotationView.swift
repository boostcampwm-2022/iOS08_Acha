//
//  PlayerAnnotationView.swift
//  Acha
//
//  Created by hong on 2022/12/07.
//

import Foundation
import MapKit

final class PlayerAnnotationView: MKAnnotationView {
    
    static let identifier = String(describing: PlayerAnnotationView.self)
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        guard let playerAnnotation = self.annotation as? PlayerAnnotation else {return}
        image = playerAnnotation.image()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
