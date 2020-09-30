//
//  Map.swift
//  Stepify
//
//  Created by JJ Zapata on 9/26/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class Map: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView : MKMapView!
    
    var x : Float = 0
    var y : Float = 0
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: CLLocationDegrees(self.x), longitude: CLLocationDegrees(self.y)), span: span)
        
        mapView.setRegion(region, animated: true)

        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Hel2lo")
        if let location = locations.first {
            self.x = Float(location.coordinate.longitude)
            self.y = Float(location.coordinate.latitude)
            print(x)
            print(y)
        }
    }

}
