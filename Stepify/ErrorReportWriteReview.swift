//
//  ErrorReportWriteReview.swift
//  Stepify
//
//  Created by JJ Zapata on 10/5/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ErrorReportWriteReview: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var textField : UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textField.delegate = self

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submit(_ sender: UIButton) {
        Database.database().reference().child("Reports").childByAutoId().setValue("\(Auth.auth().currentUser!.uid) - " + "\(self.textField!.text!)")
        let alert = UIAlertController(title: "Submitted", message: "Your message has been sumbitted successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
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
