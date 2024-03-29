//
//  Sign In.swift
//  Stepify
//
//  Created by JJ Zapata on 9/24/20.
//  Copyright © 2020 Jorge Zapata. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import AuthenticationServices
import GoogleSignIn
import CryptoKit

class Sign_In: UIViewController, UITextFieldDelegate, ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate, GIDSignInDelegate {
    
    @IBOutlet var email : UITextField!
    @IBOutlet var password : UITextField!
    
    @IBOutlet var signInButton : UIButton!
    
    var myNameFromAlert = ""
    var memberSinceString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.OnboardingBoolean()
        self.TextFieldSetup()
        self.ButtonsSetup()
        self.MemberSinceCalc()

        // Do any additional setup after loading the view.
    }
    
    func MemberSinceCalc() {
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let currentYearInt = (calendar?.component(NSCalendar.Unit.year, from: Date()))!
        let currentMonthInt = (calendar?.component(NSCalendar.Unit.month, from: Date()))!
        
        memberSinceString = "\(currentMonthInt)/\(currentYearInt)"
        print(memberSinceString)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Auth.auth().currentUser != nil {
            // advance to next screen
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc: UIViewController = sb.instantiateViewController(withIdentifier: "TabBarMain") as! MainTabBarController
            UIApplication.shared.keyWindow?.rootViewController = vc
        }
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    func OnboardingBoolean() {
        if UserDefaults.standard.bool(forKey: "onboardingSeen") == false {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc: UIViewController = sb.instantiateViewController(withIdentifier: "OnboardingScreen1Nav") as! NavControllerView
            UIApplication.shared.keyWindow?.rootViewController = vc
        } else {
            print("Hello")
        }
    }
    
    @IBAction func appleButtonPressed(_ sender: UIButton) {
        print("apple button pressed")
        self.startSignInWithAppleFlow()
        
    }
    
    @IBAction func googleButtonPressed(_ sender: UIButton) {
        self.handleGoogleSignIn()
    }
    
    @IBAction func mainButtonPressed(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { (result, error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else {
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc: UIViewController = sb.instantiateViewController(withIdentifier: "TabBarMain") as! MainTabBarController
                UIApplication.shared.keyWindow?.rootViewController = vc
            }
        }
    }
    
    func ButtonsSetup() {
        self.signInButton.layer.cornerRadius = 10
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.ResetTextFieldBorders()
        self.view.endEditing(true)
    }
    
    func TextFieldSetup() {
        self.email.delegate = self
        self.email.layer.borderWidth = 0
        self.email.layer.cornerRadius = 10
        self.email.layer.borderColor = UIColor(named: "textfieldColor")?.cgColor
        
        self.password.delegate = self
        self.password.layer.borderWidth = 0
        self.password.layer.cornerRadius = 10
        self.password.layer.borderColor = UIColor(named: "textfieldColor")?.cgColor
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
            case self.email:self.email.delegate = self
                self.email.layer.borderWidth = 2
                self.email.layer.cornerRadius = 10
                self.email.layer.borderColor = UIColor(named: "primaryColor")?.cgColor
                
                self.password.delegate = self
                self.password.layer.borderWidth = 0
                self.password.layer.cornerRadius = 10
                self.password.layer.borderColor = UIColor(named: "textfieldColor")?.cgColor
            case self.password:
                self.email.delegate = self
                self.email.layer.borderWidth = 0
                self.email.layer.cornerRadius = 10
                self.email.layer.borderColor = UIColor(named: "textfieldColor")?.cgColor
                
                self.password.delegate = self
                self.password.layer.borderWidth = 2
                self.password.layer.cornerRadius = 10
                self.password.layer.borderColor = UIColor(named: "primaryColor")?.cgColor
            default:
                print("Another tf")
            }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.ResetTextFieldBorders()
        textField.resignFirstResponder()
        return (true)
    }
    
    func ResetTextFieldBorders() {
        self.email.delegate = self
        self.email.layer.borderWidth = 0
        self.email.layer.cornerRadius = 10
        self.email.layer.borderColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1).cgColor
        
        self.password.delegate = self
        self.password.layer.borderWidth = 0
        self.password.layer.cornerRadius = 10
        self.password.layer.borderColor = UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1).cgColor
    }
    
    // Unhashed nonce.

        var currentNonce: String?

     @available(iOS 13, *)

            func startSignInWithAppleFlow() {

              let nonce = randomNonceString()

              currentNonce = nonce

              let appleIDProvider = ASAuthorizationAppleIDProvider()

              let request = appleIDProvider.createRequest()

        request.requestedScopes = [.email]

                print(request.requestedScopes)

              request.nonce = sha256(nonce)



              let authorizationController = ASAuthorizationController(authorizationRequests: [request])

              authorizationController.delegate = self

              authorizationController.presentationContextProvider = self

              authorizationController.performRequests()

            }



            @available(iOS 13, *)

             func sha256(_ input: String) -> String {

              let inputData = Data(input.utf8)

              let hashedData = SHA256.hash(data: inputData)

              let hashString = hashedData.compactMap {

                return String(format: "%02x", $0)

              }.joined()



              return hashString

            }



            // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce

             func randomNonceString(length: Int = 32) -> String {

              precondition(length > 0)

              let charset: Array<Character> =

                  Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

              var result = ""

              var remainingLength = length



              while remainingLength > 0 {

                let randoms: [UInt8] = (0 ..< 16).map { _ in

                  var random: UInt8 = 0

                  let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)

                  if errorCode != errSecSuccess {

                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")

                  }

                  return random

                }



                randoms.forEach { random in

                  if remainingLength == 0 {

                    return

                  }



                  if random < charset.count {

                    result.append(charset[Int(random)])

                    remainingLength -= 1

                  }

                }

              }



              return result

            }



            func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {

                return self.view.window!

            }



                  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

                    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {

                      guard let nonce = currentNonce else {

                        fatalError("Invalid state: A login callback was received, but no login request was sent.")

                      }

                      guard let appleIDToken = appleIDCredential.identityToken else {

                        print("Unable to fetch identity token")

                        return

                      }

                      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {

                        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")

                        return

                      }

                      // Initialize a Firebase credential.

                      let credential = OAuthProvider.credential(withProviderID: "apple.com",

                                                                idToken: idTokenString,

                                                                rawNonce: nonce)

                        print("Up To Firebase Now")

                      // Sign in with Firebase.

                      Auth.auth().signIn(with: credential) { (authResult, error) in

                        if error != nil {

                          // Error. If error.code == .MissingOrInvalidNonce, make sure

                          // you're sending the SHA256-hashed nonce as a hex string with

                          // your request to Apple.

                            print(error!.localizedDescription)

                          return

                        }

                        print("Fine")
                        let sb = UIStoryboard(name: "Main", bundle: nil)
                        let vc: UIViewController = sb.instantiateViewController(withIdentifier: "TabBarMain") as! MainTabBarController
                        UIApplication.shared.keyWindow?.rootViewController = vc

                                }


                  }



                  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {

                    // Handle error.

                    print("Sign in with Apple errored: \(error)")

                    // Handle error.

                    let errror = error.localizedDescription

                    let alert = UIAlertController(title: "Fehler", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)

                    print("Sign in with Apple errored: \(errror)")

                  }



                }

            func handleGoogleSignIn() {
                GIDSignIn.sharedInstance()?.signIn()
            }

            func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
                if let error = error {
                    print("1There was an error:" + error.localizedDescription)
                    return
                }
                guard let authentication = user.authentication else { return }
                let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
                Auth.auth().signIn(with: credential) { (result, error) in
                    if let error = error {
                        print("2There was an error:" + error.localizedDescription)
                        return
                    }
                    guard let uid = result?.user.uid else { return }
                    guard let email = result?.user.email else { return }
                    guard let username = result?.user.displayName else { return }
                    print("uid: \(uid), email: \(email), username: \(username)")
                    let values = [
                    
                    "uid" : String(Auth.auth().currentUser!.uid),

                    "email" : String(Auth.auth().currentUser!.email!),

                    "firstname" : "\(username)",

                    "lastname" : "noLastName",

                    "steps" : 0,

                    "memberSince" : "\(self.memberSinceString)",
                        
                    "profilePhoto" : "https://lh5.googleusercontent.com/ZZJ8nSJxHSN9Tw9YZ4JUFU4E6BFxUG3uiRKMTGL51WrStNK2zpX6maEVj_KxMC9wVwJDHvzE=w1280"
                    ] as [String : Any]
                    Database.database().reference().child("Users").child(uid).updateChildValues(values) { (error, result) in
                        let sb = UIStoryboard(name: "Main", bundle: nil)
                        let vc: UIViewController = sb.instantiateViewController(withIdentifier: "TabBarMain") as! MainTabBarController
                        UIApplication.shared.keyWindow?.rootViewController = vc
                    }
                }
            }


}
