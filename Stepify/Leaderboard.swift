//
//  Leaderboard.swift
//  Stepify
//
//  Created by JJ Zapata on 9/27/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Kingfisher
import FirebaseAuth
import MBProgressHUD
import GoogleMobileAds

class Leaderboard: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, GADBannerViewDelegate {
    
    @IBOutlet var segmentedControl : UISegmentedControl!
    @IBOutlet var tableView : UITableView!
    @IBOutlet var bannerView : GADBannerView!
    
    var allUsers = [Leaderboard_User_Object]()
    var searchFriends = [Leaderboard_Friend_Object]()
    var openIndex = 0
    var importantNBool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let selectedAtributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                 NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)]
        self.segmentedControl.setTitleTextAttributes(selectedAtributes, for: .selected)
                        
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.adUnitID = "ca-app-pub-2433250329496395/8290515453"
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
    
    @IBAction func segemntedControlChanged(_ sender: UISegmentedControl) {
        viewWillAppear(true)
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
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Friends").observe(.childAdded) { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                let user = Leaderboard_Friend_Object()
                user.uid = value["uid"] as? String ?? "Error"
                
                Database.database().reference().child("Users").child(user.uid!).child("steps").observe(.value) { (snapshot) in
                    print("finding steps")
                    let value = snapshot.value as? NSNumber
                    let notOptional = value
                    if let integer = notOptional {
                        user.steps = Int(integer)
                        self.importantNBool = true
                    } else {
                        user.steps = Int(0)
                        self.importantNBool = true
                    }
                }
                self.searchFriends.append(user)
            }
            self.tableView.reloadData()
        }
    }
    
    func SetupCollectionLayout() {
        self.AllUsers()
        self.AllFriends()
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
            return self.searchFriends.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.segmentedControl.selectedSegmentIndex == 0 {
            // all users
            let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardFriends", for: indexPath) as! Leaderboard_Cell
            let url = URL(string: self.allUsers[indexPath.row].profileImageUrl!)
            cell.profileImage.kf.setImage(with: url)
//            cell.profileImage.downloaded(from: url!)
            cell.titleName.text = self.allUsers[indexPath.row].name!
            cell.stepCount.text = String("\(self.allUsers[indexPath.row].steps!) Steps")
            cell.emojiButton.imageView?.translatesAutoresizingMaskIntoConstraints = false
            cell.emojiButton.imageView?.clipsToBounds = true
            cell.emojiButton.imageView?.contentMode = .scaleToFill
            cell.emojiButton.tag = indexPath.row
            cell.emojiButton.addTarget(self, action: #selector(openPopup), for: .touchUpInside)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardFriends", for: indexPath) as! Leaderboard_Cell
            cell.emojiButton.addTarget(self, action: #selector(openPopup), for: .touchUpInside)
            Database.database().reference().child("Users").child(self.searchFriends[indexPath.row].uid!).child("steps").observe(.value) { (steps) in
                
                
                let value = steps.value as? NSNumber
                let notOptional = value
                if let integer = notOptional {
                    self.searchFriends.sort(by: { $1.steps! < $0.steps!})
                    Database.database().reference().child("Users").child(self.searchFriends[indexPath.row].uid!).child("firstname").observe(.value) { (firstname) in
                        if let firstname : String = (firstname.value as? String) {
                            cell.titleName!.text! = firstname
                            Database.database().reference().child("Users").child(self.searchFriends[indexPath.row].uid!).child("profilePhoto").observe(.value) { (photoURL) in
                                if let profilePhoto : String = (photoURL.value as? String) {
                                    cell.profileImage.loadImageUsingCacheWithUrlString(profilePhoto)
                                    Database.database().reference().child("Users").child(self.searchFriends[indexPath.row].uid!).child("email").observe(.value) { (email) in
                                        if let emailOfUser : String = (email.value as? String) {
                                            cell.stepCount!.text! = emailOfUser
                                            Database.database().reference().child("Users").child(self.searchFriends[indexPath.row].uid!).child("steps").observe(.value) { (steps) in
                                                let value = steps.value as? NSNumber
                                                let notOptional = value
                                                if let integer = notOptional {
                                                    cell.stepCount!.text! = String("\(integer) Steps")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            cell.titleName!.text! = "Deleted user"
                        }
                    }
                }
            }
            return cell
        }
    }
    
    @objc func openPopup(_ sender: UIButton) {
        // tell global variables the tapped uid
        let indexPathRow = sender.tag
        if self.segmentedControl.selectedSegmentIndex == 0 {
            GlobalVariables.uidTappedFromLeaderboard = "\(self.allUsers[indexPathRow].uid!)"
            self.tossUpReaction()
        } else {
            GlobalVariables.uidTappedFromLeaderboard = "\(self.searchFriends[indexPathRow].uid!)"
            self.tossUpReaction()
        }
    }
    
    @IBAction func add(_ sender: UIButton) {
        self.share()
    }
    
    func share() {
        Database.database().reference().child("appStoreLink").observe(.value, with: { (data) in
            let qqqq : String = (data.value as? String)!
            let activityVC = UIActivityViewController(activityItems: ["\(qqqq)"], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        })
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
            
            Database.database().reference().child("Users").child(self.searchFriends[openIndex].uid!).child("profilePhoto").observe(.value) { (firstname) in
                if let profilePhoto : String = (firstname.value as? String) {
                    secondController.imageURL = profilePhoto
                } else {
                    secondController.imageURL = "https://www.google.com/url?q=https://is4-ssl.mzstatic.com/image/thumb/Purple124/v4/bc/5c/2f/bc5c2f80-f2d9-de4d-1fef-f2170e45a717/AppIcon-0-1x_U007emarketing-0-7-0-85-220.png/492x0w.png&source=gmail&ust=1602418896999000&usg=AFQjCNE2ygJQZOFtAx3kKhzRkhvy6aGezA"
                }
            }
            
            Database.database().reference().child("Users").child(self.searchFriends[openIndex].uid!).child("firstname").observe(.value) { (firstname) in
                let firstname : String = (firstname.value as? String)!
                secondController.nameOfUser = firstname
            }
            
            Database.database().reference().child("Users").child(self.searchFriends[openIndex].uid!).child("steps").observe(.value) { (steps) in
                let value = steps.value as? NSNumber
                let integer = Int(value!)
                secondController.stepCount = integer
            }
            
            Database.database().reference().child("Users").child(self.searchFriends[openIndex].uid!).child("email").observe(.value) { (emaiil) in
                let email : String = (emaiil.value as? String)!
                secondController.emailAddress = email
            }
            
            secondController.isFriends = true
            secondController.uid = self.searchFriends[openIndex].uid!
        }
    }
    
    func tossUpReaction() {
        let slideVC = OverlayView()
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        self.present(slideVC, animated: true, completion: nil)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}
