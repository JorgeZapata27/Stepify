//
//  Leaderboard.swift
//  Stepify
//
//  Created by JJ Zapata on 9/27/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import MBProgressHUD
import GoogleMobileAds

class Leaderboard: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    @IBOutlet var segmentedControl : UISegmentedControl!
    @IBOutlet var tableView : UITableView!
    @IBOutlet var bannerView : GADBannerView!
    
    var allUsers = [Leaderboard_User_Object]()
    var allFriends = [Leaderboard_User_Object]()
    var searchFriends = [Leaderboard_Friend_Object]()
    var openIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let selectedAtributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                 NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)]
        self.segmentedControl.setTitleTextAttributes(selectedAtributes, for: .selected)
                        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//        bannerView.adUnitID = "ca-app-pub-2433250329496395/8290515453" REAL
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())

        // Do any additional setup after loading the view.
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let Indicator = MBProgressHUD.showAdded(to: self.view, animated: true)
        Indicator.label.text = "Working"
        Indicator.isUserInteractionEnabled = false
        Indicator.detailsLabel.text = "Setting up your account"
        Indicator.show(animated: true)
        
        SetupCollectionLayout()
        
        Indicator.hide(animated: true)
    }
    
    fileprivate func AllUsers() {
        self.allUsers.removeAll()
        Database.database().reference().child("Users").observe(.childAdded) { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                let user = Leaderboard_User_Object()
                user.uid = value["uid"] as? String ?? "Error"
                user.name = value["firstname"] as? String ?? "Error"
                user.steps = value["steps"] as? Int ?? 0
                user.email = value["email"] as? String ?? "Error"
                user.profileImageUrl = value["profilePhoto"] as? String ?? "Error"
                self.allUsers.append(user)
            }
            self.allUsers.sort(by: { $1.steps! < $0.steps!})
            self.tableView.reloadData()
        }
    }
    
    fileprivate func AllFriends() {
        // get uids
        self.searchFriends.removeAll()
        self.allFriends.removeAll()
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
//                    print("self.allFriends")
//                    print(self.allFriends)
//                    print("self.allFriends")
                    
                    self.allFriends.sort(by: { $1.steps! < $0.steps!})
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func SetupCollectionLayout() {
        self.AllUsers()
        self.AllFriends()
    }
    
    @IBAction func segemntedControlChanged(_ sender: UISegmentedControl) {
        viewWillAppear(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.segmentedControl.selectedSegmentIndex == 0 {
            // all users
            return self.allUsers.count
        } else {
            // friends
            return self.allFriends.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.segmentedControl.selectedSegmentIndex == 0 {
            
            // all users
            let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardFriends", for: indexPath) as! Leaderboard_Cell
            cell.profileImage.loadImageUsingCacheWithUrlString(self.allUsers[indexPath.row].profileImageUrl!)
            cell.titleName.text = self.allUsers[indexPath.row].name!
            cell.stepCount.text = String("\(self.allUsers[indexPath.row].steps!) Steps")
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardFriends", for: indexPath) as! Leaderboard_Cell
            cell.profileImage.loadImageUsingCacheWithUrlString(self.allFriends[indexPath.row].profileImageUrl!)
            cell.titleName.text = self.allFriends[indexPath.row].name!
            cell.stepCount.text = String("\(self.allFriends[indexPath.row].steps!) Steps")
            return cell
            // friends
        }
    }
    
    func hello() {
        let key = Database.database().reference().child("Users").childByAutoId().key
        let friends = ["uid" : "\(Auth.auth().currentUser!.uid)"] as [String : Any]
        let totalList = ["\(key!)" : friends]
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Friends").updateChildValues(totalList)
    }
    
    @IBAction func add(_ sender: UIButton) {
        //
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.segmentedControl.selectedSegmentIndex == 0 {
            // all users
            openIndex = indexPath.row
            self.performSegue(withIdentifier: "toUserFromLeaderboard", sender: self)
            // open profile
            print("open profile")
        } else {
            // friends
            openIndex = indexPath.row
            self.performSegue(withIdentifier: "toFriendFromLeaderboard", sender: self)
            // open profile
            print("open profile")
        }
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("received")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error.localizedDescription)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserFromLeaderboard" {
            let secondController = segue.destination as! User_Profile
            secondController.imageURL = self.allUsers[openIndex].profileImageUrl!
            secondController.nameOfUser = self.allUsers[openIndex].name!
            secondController.emailAddress = self.allUsers[openIndex].email!
            secondController.stepCount = self.allUsers[openIndex].steps!
            secondController.uid = self.allUsers[openIndex].uid!
            secondController.isFriends = false
        } else if segue.identifier == "toFriendFromLeaderboard" {
            let secondController = segue.destination as! User_Profile
            secondController.imageURL = self.allFriends[openIndex].profileImageUrl!
            secondController.nameOfUser = self.allFriends[openIndex].name!
            secondController.uid = self.allFriends[openIndex].uid!
            secondController.emailAddress = self.allFriends[openIndex].email!
            secondController.stepCount = self.allFriends[openIndex].steps!
            secondController.isFriends = true
        }
    }
    
}
