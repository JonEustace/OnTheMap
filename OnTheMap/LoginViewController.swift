//
//  ViewController.swift
//  OnTheMap
//
//  Created by iMac on 2016-02-25.
//  Copyright © 2016 iMac. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    let uda = UdacityClient()
    let p = ParseClient()
    
    var appDelegate : AppDelegate!
    @IBOutlet weak var loginView: FBSDKLoginButton!
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        _ = FBSDKLoginButton()
        self.navigationController?.navigationBarHidden = true
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            
            setAppdelegateFromFB()
            
        }
        else
        {
            
            loginView.readPermissions = ["public_profile", "email"]
            loginView.delegate = self
        }
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
             alert("There FB login, please try again")
        }
        else if result.isCancelled {
            // Handle cancellations
            alert("You cancelled FB login, please try again")
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                print("hello")
                print(FBSDKAccessToken.currentAccessToken())
                
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func setAppdelegateFromFB(){
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "first_name, last_name"])
        
        request.startWithCompletionHandler({ (connection, result, error) in
            
            if error != nil{
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.alert("There was an error logging in with Facebook")
                }
            }
            
            self.appDelegate.sessionID = FBSDKAccessToken.currentAccessToken().userID
            self.appDelegate.firstName = result["first_name"] as? String
            self.appDelegate.lastName = result["last_name"] as? String
            
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("MapListSegue", sender: nil)
            }
        })
        
        
        
    }
    
    @IBAction func login(sender: UIButton) {
        
        guard (Reachability.isConnectedToNetwork() == true) else{
            
            alert("No network connectivity")
            return
        }
        
        if username.text == "" || password.text == "" {
            self.alert("Missing Username or Password")
            
        } else {
            uda.createSession(username.text!, password: password.text!, returnedSessionID: { (sessionID, error) -> Void in
                
                guard error.code == 0 else{
                    dispatch_async(dispatch_get_main_queue()) {
                        self.alert("Login Error")
                    }
                    
                    return
                }
                
                let key = sessionID["accountKey"]
                
                self.uda.getUserData(key as! String, returnedUserInfo: { (userInfo, error) -> Void in
                    
                    self.appDelegate.firstName = userInfo["firstName"]! as? String
                    self.appDelegate.lastName = userInfo["lastName"]! as? String
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("MapListSegue", sender: nil)
                    }
                    
                })
                
            })
        }
    }

}

