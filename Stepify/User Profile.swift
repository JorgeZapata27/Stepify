//
//  User Profile.swift
//  Stepify
//
//  Created by JJ Zapata on 9/29/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class User_Profile: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet var profileImageView : UIImageView!
    @IBOutlet var name : UILabel!
    @IBOutlet var email : UILabel!
    @IBOutlet var step : UILabel!
    @IBOutlet var friendsButton : UIButton!
    @IBOutlet var bannerView : GADBannerView!
    
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
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//      bannerView.adUnitID = "ca-app-pub-2433250329496395/7051803010" REAL
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
        
        self.friendsButton.layer.cornerRadius = 12
        self.profileImageView.layer.cornerRadius = 62.5

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.profileImageView.loadImageUsingCacheWithUrlString(imageURL)
        self.name!.text! = nameOfUser
        self.email!.text! = emailAddress
        self.step!.text! = String("\(stepCount) Steps")
        
        if self.isFriends == true {
            // friends
            self.friendsButton.setTitle("Remove from Friends", for: .normal)
        } else {
            // not friends
            self.friendsButton.setTitle("Add to Friends", for: .normal)
        }
    }
    
    func addAsFriend() {
        // get list
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Friends").observe(.childAdded, with: { (snapshot) in
                    if let value = snapshot.value as? [String : Any] {
                        let user = Leaderboard_Friend_Object()
                        user.uid = value["uid"] as? String ?? "Error"
                        // put into uid array
                        self.searchFriends.append(user)
                    }
                    for friend in self.searchFriends {
                        print(friend.uid!)
                    }
                    // with uid array, add info in a friend array similar to all users.
                    for user in self.searchFriends {
                        print("found user")
                        print(user.uid!)
                        Database.database().reference().child("Users").child(user.uid!).observe(.value) { (snapshot) in
                            if let value = snapshot.value as? [String : Any] {
                                let user = Leaderboard_User_Object()
                                user.uid = value["uid"] as? String ?? "Error"
                                user.name = value["firstname"] as? String ?? "Error"
                                user.steps = value["steps"] as? Int ?? 0
                                user.email = value["email"] as? String ?? "Error"
                                user.profileImageUrl = value["profilePhoto"] as? String ?? "Error"
                                print(user.uid!)
                                print(user.name!)
                                print(user.steps!)
                                print(user.profileImageUrl!)
                                self.allFriends.append(user)
                            }
                            let currentUser = Leaderboard_User_Object()
                            currentUser.uid = self.uid
                            currentUser.name = self.nameOfUser
                            currentUser.steps = self.stepCount
                            currentUser.email = self.emailAddress
                            currentUser.profileImageUrl = self.imageURL
                            print("currentUser")
                            print(currentUser)
                            print(currentUser.uid!)
                            print("currentUser")
                            print("Array User")
                            for friend in self.allFriends {
                                print(friend.uid!)
                            }
                            print("Array User")
                            if self.allFriends.contains(where: { $0.uid == self.uid }) {
                                print("USER WILL BE REMOVED")
                                Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Friends").child(self.uid).removeValue()
                                // alert of success
                            } else {
                                print("USER WILL BE ADDED")
                                let friends = ["uid" : "\(self.uid)"] as [String : Any]
                                let totalList = ["\(self.uid)" : friends]
                                Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Friends").updateChildValues(totalList)
                                // alert of success
                            }
                        }
                    }
                })
        
        // if list contains, do nothing
        // else, add
        
//        let key = Database.database().reference().child("Users").childByAutoId().key
//        let friends = ["uid" : "\(Auth.auth().currentUser!.uid)"] as [String : Any]
//        let totalList = ["\(key!)" : friends]
//        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Friends").updateChildValues(totalList)
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("received")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error.localizedDescription)
    }
    
    @IBAction func mainButtonPressefd(_ sender: UIButton) {
        self.addAsFriend()
    }

}
