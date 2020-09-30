//
//  Add Photo.swift
//  Stepify
//
//  Created by JJ Zapata on 9/25/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import AuthenticationServices
import CryptoKit
import MBProgressHUD

class Add_Photo: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imageToUpload : UIImageView!
    @IBOutlet var finishButton : UIButton!
    
    let pickerController = UIImagePickerController()
    
    var status = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = .photoLibrary
        
        self.finishButton.layer.cornerRadius = 10
        
        self.navigationController?.navigationBar.isHidden = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func finishSetupPressed(_ sender: UIButton) {
        if self.status != false {
            let Indicator = MBProgressHUD.showAdded(to: self.view, animated: true)
            Indicator.label.text = "Working"
            Indicator.isUserInteractionEnabled = false
            Indicator.detailsLabel.text = "Setting up your account"
            Indicator.show(animated: true)
            guard let imageData = imageToUpload.image?.jpegData(compressionQuality: 0.75) else { return }
            let storageRef = Storage.storage().reference()
            let storageProfileRef = storageRef.child("Profiles").child("\(Auth.auth().currentUser!.uid)").child("ProfileImage")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            storageProfileRef.putData(imageData, metadata: metadata) { (storageMetadata, error2) in
                if error2 != nil {
                    print(error2!.localizedDescription)
                    print("ERROR1")
                    return
                }
                storageProfileRef.downloadURL { (url, error3) in
                    if let metaImageURL = url?.absoluteString {
                        print(metaImageURL)
                        Database.database().reference().child("Users").child((Auth.auth().currentUser!.uid)).child("profilePhoto").setValue(metaImageURL)
                        let sb = UIStoryboard(name: "Main", bundle: nil)
                        let vc: UIViewController = sb.instantiateViewController(withIdentifier: "TabBarMain") as! MainTabBarController
                        UIApplication.shared.keyWindow?.rootViewController = vc
                    } else {
                        print(error3!.localizedDescription)
                    }
                }
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Pick a profile picture!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func photoChangePressed(_ sender: UIButton) {
        // get permissions
        // done
        
        // prompt permissions
        // waiting
        
        // present
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            // show as new photo
            self.imageToUpload.image = image
            // mark status as true
            self.status = true
            self.pickerController.dismiss(animated: true, completion: nil)
        }

        if let editedImage = info[.originalImage] as? UIImage {
            // show as new photo
            self.imageToUpload.image = editedImage
            // mark status as true
            self.status = true
            self.pickerController.dismiss(animated: true, completion: nil)
        }
    }

}



