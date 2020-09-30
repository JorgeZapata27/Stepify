//
//  Onboarding2.swift
//  Stepify
//
//  Created by JJ Zapata on 9/24/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import CoreLocation

class Onboarding2: UIViewController, CLLocationManagerDelegate {
    
    var locationManager : CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.performSegue(withIdentifier: "toOnboarding3", sender: self)
        } else {
            let alert = UIAlertController(title: "Error", message: "Please Allow Location For App", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}
