//
//  Notifications Controller.swift
//  Stepify
//
//  Created by JJ Zapata on 10/3/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import MBProgressHUD

class Notifications_Controller: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var notifications = [NotificationObject]()
    var openIndex = 0
    
    @IBOutlet var tableView : UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func stripElements<T>(in array:[T]) -> [T] {
        return array.enumerated().filter { (arg0) -> Bool in
            let (offset, _) = arg0
            return offset % 2 != 0
            }.map { $0.element }
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
    
    func AllUsers() {
        print("all usering")
        self.notifications.removeAll()
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Notifications").observe(.childAdded) { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                let notification = NotificationObject()
                notification.message = value["emojiMessage"] as? String ?? "Error"
                notification.uid = value["senderUid"] as? String ?? "Error"
                self.notifications.append(notification)
            }
            self.notifications.reverse()
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
        return self.notifications.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notifications", for: indexPath) as! Leaderboard_Cell
        let uid = notifications[indexPath.row].uid!
        Database.database().reference().child("Users").child(uid).child("firstname").observe(.value, with: { (data) in
            let name : String = (data.value as? String)!
            cell.titleName!.text! = "\(name) Reacted: \(self.notifications[indexPath.row].message!)"
        })
        Database.database().reference().child("Users").child(uid).child("profilePhoto").observe(.value, with: { (data) in
            let url : String = (data.value as? String)!
            cell.profileImage.loadImageUsingCacheWithUrlString(url)
        })
        return cell
    }
    
    @IBAction func clearNotifications(_ sender: UIButton) {
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("Notifications").removeValue()
        // run all users
        self.AllUsers()
        // alert
        let alert = UIAlertController(title: "Done", message: "Your Notification Inbox Has Been Cleared", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            // dismiss / pop view controller
            self.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
