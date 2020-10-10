//
//  Forgot Password.swift
//  Stepify
//
//  Created by JJ Zapata on 9/26/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleMobileAds

class Forgot_Password: UIViewController, UITextFieldDelegate, GADBannerViewDelegate {
    
    @IBOutlet var email : UITextField!
    @IBOutlet var signUpButton : UIButton!
    @IBOutlet var bannerView : GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.TextFieldSetup()
        self.ButtonsSetup()
        
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.adUnitID = "ca-app-pub-2433250329496395/4871689786"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())

        // Do any additional setup after loading the view.
    }

    
    func TextFieldSetup() {
        self.email.delegate = self
        self.email.layer.borderWidth = 0
        self.email.layer.cornerRadius = 10
        self.email.layer.borderColor = UIColor(named: "textfieldColor")?.cgColor
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case self.email:
            self.email.delegate = self
            self.email.layer.borderWidth = 2
            self.email.layer.cornerRadius = 10
            self.email.layer.borderColor = UIColor(named: "primaryColor")?.cgColor
        default:
            print("Another tf")
        }
    }
    
    func ButtonsSetup() {
        self.signUpButton.layer.cornerRadius = 10
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.ResetTextFieldBorders()
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.ResetTextFieldBorders()
        textField.resignFirstResponder()
        return (true)
    }
    
    func ResetTextFieldBorders() {
        self.email.delegate = self
        self.email.layer.borderWidth = 0
        self.email.layer.cornerRadius = 10
        self.email.layer.borderColor = UIColor(named: "textfieldColor")?.cgColor
    }
    
    @IBAction func mainButtonPressed(_ sender: UIButton) {
        Auth.auth().sendPasswordReset(withEmail: self.email.text!) { (error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.performSegue(withIdentifier: "toSuccessFP", sender: self)
            }
        }
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("received")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error.localizedDescription)
    }

}


