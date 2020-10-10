//
//  Map.swift
//  Stepify
//
//  Created by JJ Zapata on 9/26/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import CoreLocation
import MBProgressHUD
import FirebaseDatabase

class CustomPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var profileImageUrl : String?
    
    init(pinTitle: String, pinSubtitle: String, location: CLLocationCoordinate2D, profileImageUrl: String) {
        self.subtitle = pinSubtitle
        self.title = pinTitle
        self.coordinate = location
        self.profileImageUrl = profileImageUrl
    }
}

class Map: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var imageViewofUser : UIImageView!
    
    var location : CLLocation?
    var waiting = true
    var imageURL = ""
    var allUsers = [Leaderboard_User_Object]()
    
    @IBOutlet var mapView : MKMapView!
    
    var x : Float = 0
    var y : Float = 0
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if waiting == false {
            let center = self.location!.coordinate
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
            mapView.showsUserLocation = true
        }
        
        self.mapView.delegate = self
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("profilePhoto").observe(.value, with: { (data) in
            let url : String = (data.value as? String)!
            self.imageURL = url
            print("URL")
            print(url)
            print("URL")
            self.imageViewofUser.loadImageUsingCacheWithUrlString(url)
            self.waiting = false
        })
        
        self.AllUsers()
    }
    
    func AllUsers() {
        self.allUsers.removeAll()
        Database.database().reference().child("Users").observe(.childAdded) { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                let user = Leaderboard_User_Object()
                user.uid = value["uid"] as? String ?? "Error"
                user.name = value["firstname"] as? String ?? "Error"
                user.steps = value["steps"] as? Int ?? 0
                user.email = value["email"] as? String ?? "Error"
                user.profileImageUrl = value["profilePhoto"] as? String ?? "Error"
                user.long = value["longitude"] as? Double ?? 3.0
                user.lati = value["latitude"] as? Double ?? 45.0
                self.allUsers.append(user)
            }
            // remove current usee
            for user in self.allUsers {
                print(user.name!)
                print(user.long!)
                print(user.lati!)
                print("finished")
                print("adding pin..")
                
                self.addAnnotationWith(longitude: Double(user.long!), latitude: Double(user.lati!), name: user.name!, stepcount: user.steps!, profileImage: user.profileImageUrl!)
                print("added pin.")
            }
        }
    }
    
    func addAnnotationWith(longitude: Double, latitude: Double, name title: String, stepcount subtitle: Int, profileImage: String) {
        let pin = CustomPin(pinTitle: title, pinSubtitle: "\(subtitle) Steps", location: CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(longitude)), profileImageUrl: profileImage)
        self.mapView.addAnnotation(pin)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // show location on user
        // center user location
        if waiting == false {

            // get coordinates
            // upload coordinates to firebase every open page
            let longitude = location?.coordinate.longitude
            let latitude = location?.coordinate.latitude
            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("longitude").setValue(longitude)
            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("latitude").setValue(latitude)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        self.location = location
        self.viewWillAppear(true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            // user blue thingy
            
            // load for 2.5 seconds
            let Indicator = MBProgressHUD.showAdded(to: self.view, animated: true)
            Indicator.label.text = "Working"
            Indicator.isUserInteractionEnabled = false
            Indicator.detailsLabel.text = "Gathering Your Data"
            Indicator.show(animated: true)
            
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customAnnotation")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                Indicator.hide(animated: true)
                annotationView.canShowCallout = true
                annotationView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                annotationView.image = self.imageViewofUser.image!
                annotationView.layer.cornerRadius = annotationView.frame.height / 2
            }
            return annotationView
        } else {
            // other users
            
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customAnnotation")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                annotationView.canShowCallout = true
                annotationView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                annotationView.image = UIImage(named: "stepifyappicon")
                annotationView.layer.cornerRadius = annotationView.frame.height / 2
            }
            return annotationView
        }
    }
    
    

}
