//
//  AnnotationPin.swift
//  Stepify
//
//  Created by JJ Zapata on 10/3/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import MapKit

class AnnotationPin: NSObject, MKAnnotation {
    
    var title : String?
    var subtitle : String?
    var coordinate : CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }

}
