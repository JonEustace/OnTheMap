//
//  ListViewController.swift
//  OnTheMap
//
//  Created by iMac on 2016-02-26.
//  Copyright © 2016 iMac. All rights reserved.
//

import UIKit

class ListViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    let parse = ParseClient()
    var records = [[String:AnyObject]]()
    var udacityClient = UdacityClient()
    
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
          self.navigationController?.navigationBarHidden = true
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
  
    
    func loadData(){
        parse.accessParse(self, parameters: ["limit" : "50", "order" : "-updatedAt"]) { (data, error) -> Void in
            
            print(data)
            
            if error == nil{
                
                self.records = (data["results"] as? [[String:AnyObject]])!
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.table.reloadData()
                }
            } else {
                self.alert(error!.localizedDescription)
            }
        }
    }
    
    @IBAction func logout(sender: AnyObject) {
        let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("login")
        udacityClient.deleteSession()
        UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
        
        
    }
    
    @IBAction func reload(sender: AnyObject) {
        self.loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
         self.navigationController?.navigationBarHidden = true
        self.loadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return records.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell")! as! UITableViewCell
        
        let firstName = self.records[indexPath.row]["firstName"] as? String
        let lastName = self.records[indexPath.row]["lastName"] as? String
        
        cell.imageView?.image = UIImage(named:  "pin")
        cell.textLabel?.text = firstName! + " " + lastName!
        cell.detailTextLabel?.text = self.records[indexPath.row]["mediaURL"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication()
        
        if let urlString = NSURL(string: (self.records[indexPath.row]["mediaURL"] as? String)!){
            app.openURL(urlString)
        }
        
    }
    
    
    
}
