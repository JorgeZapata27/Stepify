//
//  Onboarding3.swift
//  Stepify
//
//  Created by JJ Zapata on 9/24/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import UserNotifications

class Onboarding3: UIViewController {
    
    @IBOutlet var secondaryuButton : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.secondaryuButton.layer.borderWidth = 5
        self.secondaryuButton.layer.borderColor = UIColor(named: "themeColor")?.cgColor
        self.secondaryuButton.layer.cornerRadius = 12

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        self.goToSignIn()
    }
    
    func goToSignIn() {
        UserDefaults.standard.set(true, forKey: "onboardingSeen")
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = sb.instantiateViewController(withIdentifier: "SignInNav") as! Sign_In_Nav
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    func goToSignUp() {
        UserDefaults.standard.set(true, forKey: "onboardingSeen")
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = sb.instantiateViewController(withIdentifier: "SignUpNav") as! Sign_Up_Nav
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        goToSignUp()
    }

}
