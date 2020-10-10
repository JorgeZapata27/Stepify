//
//  OverlayView.swift
//  Stepify
//
//  Created by JJ Zapata on 10/2/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import FirebaseDatabase
import FirebaseAuth
import Foundation
import UIKit

class OverlayView: UIViewController {
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    @IBOutlet weak var slideIdicator : UIView!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var emojiButtonView : UIView!
    @IBOutlet weak var completionView : UIView!
    @IBOutlet weak var completionTitle : UILabel!
    @IBOutlet weak var completionButton : UIButton!
    
    let uid = GlobalVariables.uidTappedFromLeaderboard
    
    var emojiSent = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        slideIdicator.roundCorners(.allCorners, radius: 10)
//        subscribeButton.roundCorners(.allCorners, radius: 10)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // when the reaction page is opened, set the information
        print("opening")
        print(uid)
        Database.database().reference().child("Users").child(uid).child("firstname").observe(.value, with: { (data) in
            let name : String = (data.value as? String)!
            self.titleLabel!.text! = "Send \(name) an Emoji!"
        })
        
        Database.database().reference().child("Users").child(uid).child("firstname").observe(.value, with: { (data) in
            let name : String = (data.value as? String)!
            self.completionTitle!.text! = "You sent \(name):"
        })
        
        self.emojiButtonView.isHidden = false
        self.completionView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // when the reaction page is closed, clear the variable
        GlobalVariables.uidTappedFromLeaderboard = ""
        self.emojiSent = ""
        print("globalvariable")
        print(GlobalVariables.uidTappedFromLeaderboard)
        print("globalvariable")
        print("closing")
        
        self.emojiButtonView.isHidden = false
        self.completionView.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    
    @IBAction func partyButtonPressed(_ sender: UIButton) {
        sendMessage(toUser: uid, withMessage: "🎉")
    }
    
    @IBAction func thumbsUpButtonPressed(_ sender: UIButton) {
        sendMessage(toUser: uid, withMessage: "👍")
    }
    
    @IBAction func strongButtonPressed(_ sender: UIButton) {
        sendMessage(toUser: uid, withMessage: "💪")
    }
    
    @IBAction func funnyButtonPressed(_ sender: UIButton) {
        sendMessage(toUser: uid, withMessage: "😝")
    }
    
    @IBAction func fireButtonPressed(_ sender: UIButton) {
        sendMessage(toUser: uid, withMessage: "🔥")
    }
    
    @IBAction func woahButtonPressed(_ sender: UIButton) {
        sendMessage(toUser: uid, withMessage: "😮")
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendMessage(toUser uid: String, withMessage message: String) {
//        let key = randomString(10)
        let key = Database.database().reference().child("Posts").childByAutoId().key
        let friends = ["senderUid" : "\(Auth.auth().currentUser!.uid)",
                       "emojiMessage" : "\(message)"] as [String : Any]
        let totalList = [key : friends]
        Database.database().reference().child("Users").child(uid).child("Notifications").updateChildValues(totalList)
        self.emojiSent = message
        self.completionButton.setTitle(message, for: .normal)
        self.emojiButtonView.isHidden = true
        self.completionView.isHidden = false
    }
    
    func randomString(_ n: Int) -> String {
        let digits = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        var result = ""
        for _ in 0..<n {
            result += String(digits.randomElement()!)
        }
        return result
    }
    
}
