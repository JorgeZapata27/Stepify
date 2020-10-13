//
//  CalendarDayViewController.swift
//  Stepify
//
//  Created by Neeraj Gupta on 13/10/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import HealthKit
import MBCircularProgressBar

class CalendarDayViewController: UIViewController {
    
    @IBOutlet weak var CurrentDate: UILabel!
    @IBOutlet weak var CurrentMonth: UILabel!
    @IBOutlet weak var StepsProgreeCounter: UILabel!
    @IBOutlet weak var StepsProgressView: MBCircularProgressBarView!
    @IBOutlet weak var StepsCounter: UILabel!
    @IBOutlet weak var DistanceCounter: UILabel!
    @IBOutlet weak var FlightsClimbed: UILabel!
    
    var date = Date()
    var steps = 0
    var flights = 0
    var distance = 0.0
    var startDate = Date()
    var endDate = Date()
    
    let healthKitStore: HKHealthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startDate = Calendar.current.startOfDay(for: self.date)
        self.endDate = Calendar.current.date(byAdding: .day, value: 1, to: self.date)!
        
//        functions to throw
        self.pullSteps()
        
        CurrentDate.layer.cornerRadius = CurrentDate.frame.height / 2.0
        // Do any additional setup after loading the view.
    }
    
    func pullSteps() {
        guard let sampleType = HKCategoryType.quantityType(forIdentifier: .stepCount) else {
             return
        }
        let predicate = HKQuery.predicateForSamples(withStart: self.startDate, end: self.endDate, options: .strictEndDate)
        var interval = DateComponents()
        interval.day = 1
        let query = HKStatisticsCollectionQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startDate, intervalComponents: interval)
        query.initialResultsHandler = {
            query, result, error in
            
            if let myResult = result {
                myResult.enumerateStatistics(from: self.startDate, to: self.endDate) { (statistic, value) in
                    if let count = statistic.sumQuantity() {
                        let val = count.doubleValue(for: HKUnit.count())
                        print("Total number of steps today: \(val)")
                        self.steps = Int(val)
                        print("STEPS")
                        print(self.steps)
                        print("STEPS")
//                        self.pullFlights()
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
    
    func pullFlights() {
        guard let sampleType = HKCategoryType.quantityType(forIdentifier: .flightsClimbed) else {
             return
        }
        let predicate = HKQuery.predicateForSamples(withStart: self.startDate, end: self.endDate, options: .strictEndDate)
        var interval = DateComponents()
        interval.day = 1
        let query = HKStatisticsCollectionQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startDate, intervalComponents: interval)
        query.initialResultsHandler = {
            query, result, error in
            
            if let myResult = result {
                myResult.enumerateStatistics(from: self.startDate, to: self.endDate) { (statistic, value) in
                    if let count = statistic.sumQuantity() {
                        let val = count.doubleValue(for: HKUnit.count())
                        print("Total number of steps today: \(val)")
                        self.flights = Int(val)
                        self.pullDistance()
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
    
    func pullDistance() {
        guard let sampleType = HKCategoryType.quantityType(forIdentifier: .distanceWalkingRunning) else {
             return
        }
        let predicate = HKQuery.predicateForSamples(withStart: self.startDate, end: self.endDate, options: .strictEndDate)
        var interval = DateComponents()
        interval.day = 1
        let query = HKStatisticsCollectionQuery(quantityType: sampleType, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: startDate, intervalComponents: interval)
        query.initialResultsHandler = {
            query, result, error in
            
            if let myResult = result {
                myResult.enumerateStatistics(from: self.startDate, to: self.endDate) { (statistic, value) in
                    if let count = statistic.sumQuantity() {
                        let val = count.doubleValue(for: HKUnit.count())
                        print("Total number of steps today: \(val)")
                        self.distance = val
                        self.setData()
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
    
    func setData() {
        print(self.distance)
        print(self.flights)
        print(self.steps)
    }
    
}
