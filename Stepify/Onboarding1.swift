//
//  Onboarding1.swift
//  Stepify
//
//  Created by JJ Zapata on 9/24/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import HealthKit

class Onboarding1: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        // prompt healthkit
        let readDataTypes : Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!, HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!, HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.flightsClimbed)!]
        HKHealthStore().requestAuthorization(toShare: nil, read: readDataTypes, completion: { (success, error) in
            // if success, perform segue
            if success {
                print("Authorization complete")
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toOnboarding2", sender: self)
                }
            // if error, perform segue
            } else {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toOnboarding2", sender: self)
                }
            }
        })
    }

}
