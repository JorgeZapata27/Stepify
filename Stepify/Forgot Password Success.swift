//
//  Forgot Password Success.swift
//  Stepify
//
//  Created by JJ Zapata on 9/26/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit

class Forgot_Password_Success: UIViewController {
    
    @IBOutlet var signUpButton : UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ButtonsSetup()

        // Do any additional setup after loading the view.
    }
    
    func ButtonsSetup() {
        self.signUpButton.layer.cornerRadius = 10
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.popViewController(animated: true)
    }

}
