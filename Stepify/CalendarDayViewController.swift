//
//  CalendarDayViewController.swift
//  Stepify
//
//  Created by Neeraj Gupta on 13/10/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import MBCircularProgressBar

class CalendarDayViewController: UIViewController {
    
    @IBOutlet weak var CurrentDate: UILabel!
    @IBOutlet weak var CurrentMonth: UILabel!
    @IBOutlet weak var StepsProgreeCounter: UILabel!
    @IBOutlet weak var StepsProgressView: MBCircularProgressBarView!
    @IBOutlet weak var StepsCounter: UILabel!
    @IBOutlet weak var DistanceCounter: UILabel!
    @IBOutlet weak var FlightsClimbed: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CurrentDate.layer.cornerRadius = CurrentDate.frame.height / 2.0
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
