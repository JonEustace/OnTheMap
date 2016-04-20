//
//  ViewController.swift
//  OnTheMap
//
//  Created by iMac on 2016-02-25.
//  Copyright © 2016 iMac. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let uda = UdacityClient()
    let p = ParseClient()
    
    var appDelegate : AppDelegate!
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        self.navigationController?.navigationBarHidden = true
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
       
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

