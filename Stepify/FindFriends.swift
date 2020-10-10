//
//  FindFriends.swift
//  Stepify
//
//  Created by JJ Zapata on 10/10/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import MBProgressHUD
import GoogleMobileAds

class FindFriends: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, UISearchBarDelegate {
    
    @IBOutlet var tableView : UITableView!
    @IBOutlet var searchBar : UISearchBar!
    
    var allUsers = [Leaderboard_User_Object]()
    var searchUser = [Leaderboard_User_Object]()
    var openIndex = 0
    var isSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.SetupCollectionLayout()
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
            self.allUsers.sort(by: { $0.name! < $1.name!})
            self.tableView.reloadData()
        }
    }
    
    func SetupCollectionLayout() {
        self.AllUsers()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearching {
            return self.searchUser.count
        } else {
            return self.allUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "findFriendsCell", for: indexPath) as! Leaderboard_Cell
        if self.isSearching {
            cell.titleName!.text! = self.searchUser[indexPath.row].name!
            cell.stepCount!.text! = self.searchUser[indexPath.row].email!
            cell.profileImage.loadImageUsingCacheWithUrlString(self.searchUser[indexPath.row].profileImageUrl!)
        } else {
            cell.titleName!.text! = self.allUsers[indexPath.row].name!
            cell.stepCount!.text! = self.allUsers[indexPath.row].email!
            cell.profileImage.loadImageUsingCacheWithUrlString(self.allUsers[indexPath.row].profileImageUrl!)
        }
        return cell
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
        if self.isSearching {
            let alert = UIAlertController(title: "Are you sure you want to add as a friend?", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                let friends = ["uid" : "\(self.searchUser[indexPath.row].uid!)"] as [String : Any]
                let totalList = ["\(self.searchUser[indexPath.row].uid!)" : friends]
                Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Friends").updateChildValues(totalList)
                let salert = UIAlertController(title: "Success", message: "User was added successfully!", preferredStyle: .alert)
                salert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(salert, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                print("lost a friend")
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Are you sure you want to add as a friend?", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                let friends = ["uid" : "\(self.allUsers[indexPath.row].uid!)"] as [String : Any]
                let totalList = ["\(self.allUsers[indexPath.row].uid!)" : friends]
                Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Friends").updateChildValues(totalList)
                let salert = UIAlertController(title: "Success", message: "User was added successfully!", preferredStyle: .alert)
                salert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(salert, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                print("lost a friend")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchUser = self.allUsers.filter({$0.name!.lowercased().prefix(searchText.count) == searchText.lowercased()})
        self.isSearching = true
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        self.searchBar.resignFirstResponder()
        self.isSearching = false
        self.searchBar.text = ""
        self.tableView.reloadData()
    }
    
}

