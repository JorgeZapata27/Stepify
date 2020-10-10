//
//  User Profile.swift
//  Stepify
//
//  Created by JJ Zapata on 9/29/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleMobileAds

class User_Profile: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet var profileImageView : UIImageView!
    @IBOutlet var name : UILabel!
    @IBOutlet var email : UILabel!
    @IBOutlet var step : UILabel!
    @IBOutlet var bannerView : GADBannerView!
    @IBOutlet var friendsButton : UIButton!
    
    var imageURL = ""
    var nameOfUser = ""
    var emailAddress = ""
    var stepCount = 0
    var isFriends = false
    var uid = ""
    var allFriends = [Leaderboard_User_Object]()
    var searchFriends = [Leaderboard_Friend_Object]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.isFriends == true {
            // remove
            self.friendsButton.setTitle("Remove from Friends", for: .normal)
        } else {
            // add
            self.friendsButton.setTitle("Add to Friends", for: .normal)
        }
        
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
      bannerView.adUnitID = "ca-app-pub-2433250329496395/7051803010"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
        
        self.profileImageView.layer.cornerRadius = 62.5
        self.friendsButton.layer.cornerRadius = 12

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.profileImageView.loadImageUsingCacheWithUrlString(imageURL)
        self.name!.text! = nameOfUser
        self.email!.text! = emailAddress
        self.step!.text! = String("\(stepCount) Steps")
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("received")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error.localizedDescription)
    }
    
    @IBAction func addorremoveFriend(_ sender: UIButton) {
        if self.isFriends == true {
            // remove
            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Friends").child(self.uid).removeValue()
        } else {
            // add
            let friends = ["uid" : "\(self.uid)"] as [String : Any]
            let totalList = ["\(self.uid)" : friends]
            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Friends").updateChildValues(totalList)
            // alert of success
        }
    }

}
