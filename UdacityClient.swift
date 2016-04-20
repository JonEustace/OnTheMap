//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by iMac on 2016-02-25.
//  Copyright © 2016 iMac. All rights reserved.
//

import Foundation

class UdacityClient : NSObject{
    
    
    /*MARK: 1. Create a session*/
    
    func createSession(userName : String, password : String, returnedSessionID : (sessionID : [String : AnyObject], error : NSError) -> Void) {
        
        let url = NSURL(string:"\(Udacity.ApiScheme)://www.\(Udacity.ApiHost)/\(Udacity.ApiPath)/session")!
        
        
        let body = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}"
        
        
        createPostRequest(url,body: body, completionHandlerForPost: {(data, err) in
            
            if err != nil {
                returnedSessionID(sessionID: ["sessionID" : "", "accountKey" : ""], error: err!)
               
                self.errorHandler(err!)
                return
            }
            
            guard let data = data else{
                let err = NSError(domain: "No data returned from post request", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data returned from post request"])
                self.errorHandler(err)
                returnedSessionID(sessionID: ["sessionID" : "", "accountKey" : ""], error: err)
                return
            }
            
            guard let session = data["session"] as? [String : AnyObject] else{
                let err = NSError(domain: "Could not parse session data", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not parse session data"])
                self.errorHandler(err)
                returnedSessionID(sessionID: ["sessionID" : "", "accountKey" : ""], error: err)
                return
            }
            
            guard let account = data["account"] as? [String : AnyObject] else{
                let err = NSError(domain: "Could not parse account data", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not parse account data"])
                self.errorHandler(err)
                returnedSessionID(sessionID: ["sessionID" : "", "accountKey" : ""], error: err)
                return
            }
            
            
            guard let sessionID = session["id"] as? String else{
                
                let err = NSError(domain: "Could not parse session id data", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not parse session id data"])
                self.errorHandler(err)
                returnedSessionID(sessionID: ["sessionID" : "", "accountKey" : ""], error: err)
                return
            }
            
            guard let accountKey = account["key"] as? String else{
                
                let err = NSError(domain: "Could not parse session id data", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not parse session id data"])
                self.errorHandler(err)
                returnedSessionID(sessionID: ["sessionID" : "", "accountKey" : ""], error: err)
                return
            }
           
           
            returnedSessionID(sessionID: ["sessionID" : sessionID, "accountKey" : accountKey], error: NSError(domain: "No Error", code: 0, userInfo: nil))
            
            
        })
    }
    
    func getUserData(userID : String, returnedUserInfo : (userInfo : [String:AnyObject], error : NSError) -> Void) {

        let u = userID
        let url = NSURL(string: "https://www.udacity.com/api/users/\(u)")!
      
        let request = NSMutableURLRequest(URL: url)
        
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
         
            guard (self.checkResponse(data, response: response, error: error)!.code == 0) else{
               
                returnedUserInfo(userInfo: [:], error: NSError(domain: "Error getting user information", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error getting user information"]))
                return
            }
            
            guard let returnedData = data else{
                returnedUserInfo(userInfo: [:], error: NSError(domain: "There was no Data", code: 1, userInfo: [NSLocalizedDescriptionKey: "There was no Data"]))
                return
            }
           
            let newData = returnedData.subdataWithRange(NSMakeRange(5, returnedData.length - 5)) /* subset response data! */
            
            let parsedJSON = self.parseJSON(newData)
            
            guard let user = parsedJSON["user"] as? [String:AnyObject] else{
                return
            }
    
            
            guard let lastName = user["last_name"] else {
                return
            }
            
            guard let firstName = user["first_name"] as? String else{
                return
            }
            
    
            returnedUserInfo(userInfo: ["firstName": firstName, "lastName" : lastName], error: NSError(domain: "No Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No Error"]))
        }
        task.resume()
    }
    
    /*MARK: 2. Create a Post Request*/
    func createPostRequest(url : NSURL, body : String, completionHandlerForPost: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request){ data, response, error in
            
            
            guard (self.checkResponse(data, response: response, error: error)?.code == 0) else {
                
                if error != nil{
                    self.errorHandler(error!)
                    /*new*/
                    return
                }
                
                let err = NSError(domain: "There was a problem logging in", code: 1, userInfo: [NSLocalizedDescriptionKey : "There was a problem logging in"])
                
                completionHandlerForPost(result: nil, error: err)
             
                    return
            }
            
            if let data = data{
                
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                
                let parsedResult = self.parseJSON(newData)
                completionHandlerForPost(result: parsedResult, error: nil)
            } else {
                self.errorHandler(NSError(domain: "No data was returned", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data was returned"]))
            }
        }
        
        task.resume()
        return task
    }
    
    /*MARK: 3. Check Response*/
    func checkResponse(data : NSData?, response : NSURLResponse?, error : NSError?) -> NSError?{
        guard (error == nil) else {
            
            return NSError(domain: "There was an error with your request: \(error)", code: 1, userInfo: [NSLocalizedDescriptionKey: "There was an error with your request: \(error)"])
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            
            return NSError(domain: "Your request returned a status code other than 2xx!", code: 1, userInfo: [NSLocalizedDescriptionKey: "Your request returned a status code other than 2xx!"])
            
        }
        
        /* GUARD: Was there any data returned? */
        guard let _ = data else {
            
            return NSError(domain: "No data was returned by the request!", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data was returned by the request!"])
            
        }
        
        return NSError(domain: "no Error", code: 0, userInfo: nil)
    }
    
    /*MARK: 4. Parse JSON Data*/
    func parseJSON(data : AnyObject) -> AnyObject{
        
        var parsedResult : AnyObject!
        do{
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data as! NSData, options: .AllowFragments)
        }catch{
            print("catch")
        }
        
        return parsedResult
        
    }
    
    func errorHandler(errorString : NSError){
        print(errorString.localizedDescription)
    }
    
    func deleteSession(){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }
    
}