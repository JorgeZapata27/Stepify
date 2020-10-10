//
//  Settings.swift
//  Stepify
//
//  Created by JJ Zapata on 10/3/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import StoreKit
import FirebaseAuth
import FirebaseDatabase

class Settings: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func deleteAccount(_ sender: UIButton) {
        let alert = UIAlertController(title: "Are you sure you want to delete your account?", message: "All of your information will be removed", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            let user = Auth.auth().currentUser
            let uidString = Auth.auth().currentUser!.uid

            user?.delete { error in
                // remove authenticated user
                if let error = error {
                    // An error happened.
                    let alert = UIAlertController(title: "Error deleting account", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    // Account deleted.
                    // remove firebase database information
                    Database.database().reference().child("Users").child(uidString).removeValue()
                    
                    // move to sign up page
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let vc: UIViewController = sb.instantiateViewController(withIdentifier: "SignUpNav") as! Sign_Up_Nav
                    UIApplication.shared.keyWindow?.rootViewController = vc
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
            print("Whoo thank goodness! :)")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func requestRating(_ sender: UIButton) {
        let writeReviewURL = URL(string: "https://itunes.apple.com/app/id1534533180?action=write-review")
        UIApplication.shared.open(writeReviewURL!, options: [:], completionHandler: nil)
    }
    
    @IBAction func shareStepify(_ sender: UIButton) {
        Database.database().reference().child("appStoreLink").observe(.value, with: { (data) in
            let qqqq : String = (data.value as? String)!
            let activityVC = UIActivityViewController(activityItems: ["\(qqqq)"], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        })
    }
    
    @IBAction func performSegue() {
        self.performSegue(withIdentifier: "toPhotoChoosing", sender: self)
    }
    
    @IBAction func logout(_ sender: UIButton) {
        let alet = UIAlertController(title: "Are you sure you want to logout?", message: "", preferredStyle: .alert)
        alet.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            do {
                try Auth.auth().signOut()
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc: UIViewController = sb.instantiateViewController(withIdentifier: "SignUpNav") as! Sign_Up_Nav
                UIApplication.shared.keyWindow?.rootViewController = vc
            } catch let error {
                let alert = UIAlertController(title: "Error logging out", message: "\(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        alet.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
            print("saved a user, today :)")
        }))
        self.present(alet, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoChoosing" {
            let secondController = segue.destination as! Add_Photo
            secondController.fromSettings = true
        }
    }

}
