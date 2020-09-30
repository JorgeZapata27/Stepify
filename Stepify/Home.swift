//
//  Home.swift
//  Stepify
//
//  Created by JJ Zapata on 9/26/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import HealthKit
import GoogleMobileAds
import FirebaseDatabase
import MBCircularProgressBar

class Home: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet var signInButton : UIButton!
    @IBOutlet var stepLabel : UILabel!
    @IBOutlet var progressThing : MBCircularProgressBarView!
    @IBOutlet var bannerView : GADBannerView!
    
    let healthKitStore: HKHealthStore = HKHealthStore()
    
    var valueOfSteps = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ButtonsSetup()
        
        // read healthkit
        getSteps()
                
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//        bannerView.adUnitID = "ca-app-pub-2433250329496395/3227435625" REAL
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // update firebase
//        // add steps to firebase key
//        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("steps").setValue(15200)
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("steps").setValue(valueOfSteps)
    }

    // update step progress
    func setData() {
        self.progressThing.value = CGFloat(Int(valueOfSteps))
        self.stepLabel.text = String(valueOfSteps)
        
        // update firebase
        // add steps to firebase key
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("steps").setValue(valueOfSteps)
    }
    
    func ButtonsSetup() {
        self.signInButton.layer.cornerRadius = 10
    }
    
    @IBAction func pressedShareButton(_ sender: UIButton) {
        Database.database().reference().child("appStoreLink").observe(.value, with: { (data) in
            let qqqq : String = (data.value as? String)!
            let activityVC = UIActivityViewController(activityItems: ["\(qqqq)"], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        })
    }
    
    func getSteps() {
        guard let sampleType = HKCategoryType.quantityType(forIdentifier: .stepCount) else {
             return
        }
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        var interval = DateComponents()
        interval.day = 1
        let query = HKStatisticsCollectionQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startDate, intervalComponents: interval)
        query.initialResultsHandler = {
            query, result, error in
            
            if let myResult = result {
                myResult.enumerateStatistics(from: startDate, to: Date()) { (statistic, value) in
                    if let count = statistic.sumQuantity() {
                        let val = count.doubleValue(for: HKUnit.count())
                        print("Total number of steps today: \(val)")
                        self.valueOfSteps = Int(val)
                        DispatchQueue.main.async {
                            self.setData()
                        }
                    } else {
                        print("error1")
                    }
                }
            } else {
                print("error2")
            }
        }
        healthKitStore.execute(query)
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("received")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error.localizedDescription)
    }

}
