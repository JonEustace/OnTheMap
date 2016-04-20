//
//  Reachability.swift
//  OnTheMap
//
//  Created by iMac on 2016-03-01.
//  Copyright © 2016 iMac. All rights reserved.
//
import Foundation
public class Reachability {
    
    class func isConnectedToNetwork()->Bool{
        
        var Status:Bool = false
        let url = NSURL(string: "https://google.com/")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "HEAD"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        var response: NSURLResponse?
        
        do{
        var data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response) as NSData?
        } catch {
            return false
        }
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode == 200 {
                Status = true
            }
        }
        
        return Status
    }
}