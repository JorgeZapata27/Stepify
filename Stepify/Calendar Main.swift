//
//  Calendar Main.swift
//  Stepify
//
//  Created by JJ Zapata on 10/13/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import FSCalendar

class Calendar_Main: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    @IBOutlet var calendarView : FSCalendar!
    @IBOutlet var calendareLabel : UILabel!
    @IBOutlet var subtitleViewLabel : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let modifedDate = Calendar.current.date(byAdding: .day, value: 1, to: date)
        print("date")
        print(modifedDate!)
        print("date")
        if modifedDate! < Date() {
            print("This is before")
            // pass information
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCalendarPage2" {
            //
        }
    }

}
