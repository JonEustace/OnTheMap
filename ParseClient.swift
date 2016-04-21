//
//  ParseClient.swift
//  OnTheMap
//
//  Created by iMac on 2016-02-26.
//  Copyright © 2016 iMac. All rights reserved.
//

import Foundation
import UIKit

class ParseClient : NSObject {
    
    // start a request
    func accessParse(hostViewController: UIViewController, parameters : [String : AnyObject], completionHandlerToReturnJsonObject: (data: AnyObject!, error: NSError?) -> Void){
        
        
        self.createGetRequest(parameters, completionHandlerForGet: {(data, error) in
            
            guard data != nil else{
                completionHandlerToReturnJsonObject(data: data, error: NSError(domain: "No data returned", code: 1, userInfo: [NSLocalizedDescriptionKey: "No Data Returned"]))
                return
            }
            
            self.deSerializeJSON(data, completionHandler: { (data, error) -> Void in
                guard data != nil else {
                    
                    completionHandlerToReturnJsonObject(data: nil, error: NSError(domain: "No Data returned", code: 1, userInfo: [NSLocalizedDescriptionKey: "No Data Returned"]))
                    return
                }
                completionHandlerToReturnJsonObject(data: data, error: nil)
            })
        })
    }
    
    
    func createPostRequest(parameters : [String: AnyObject], firstName : String, lastName : String, mapString : String, mediaURL : String, latitude : Double, longitude : Double, completionHandlerForPost: (data: NSData!, error: NSError) -> Void) -> NSURLSessionDataTask{
        
        let request = NSMutableURLRequest(URL: self.getQueryBuilder(parameters))
      
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //Add body to POST request
        request.HTTPBody = "{\"uniqueKey\": \"12344\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
   
        let task = session.dataTaskWithRequest(request){ (data, response, error) -> Void in
          
            guard (self.checkResponse(data, response: response, error: error)?.code == 0) else {
                if error != nil{
                    self.errorHandler(error!)
                    
                }
                return
            }
         
            guard (data != nil) else{
                 self.errorHandler(error!)
                completionHandlerForPost(data: NSData(), error: NSError(domain: "There was no data returned", code: 1, userInfo: [NSLocalizedDescriptionKey: "There was no data returned"]))
               return
                
            }
            
            completionHandlerForPost(data: data, error: self.noError())
        }
        task.resume()
        return task
        
    }
    
    //create a request and return the data
    
    func createGetRequest(parameters : [String: AnyObject], completionHandlerForGet : (data : NSData!, error : NSError) -> Void) -> NSURLSessionDataTask{
        
        let request = NSMutableURLRequest(URL: self.getQueryBuilder(parameters))
        
        request.addValue(Parse.appIDValue, forHTTPHeaderField: Parse.AppId)
        request.addValue(Parse.ApiKeyValue, forHTTPHeaderField: Parse.ApiKey)
        
        let session = NSURLSession.sharedSession()
        
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard (self.checkResponse(data, response: response, error: error)?.code == 0) else {
                if error != nil{
                    self.errorHandler(error!)
                    
                }
                return
            }
            
            guard (data != nil) else{
                completionHandlerForGet(data:NSData(), error: NSError(domain: "There was no data returned", code: 1, userInfo: [NSLocalizedDescriptionKey: "There was no data returned"]))
                
                return
            }
            completionHandlerForGet(data: data, error: self.noError())
        }
        
        task.resume()
        return task
    }
    
    // deserialize the json, handle errors if there are any
    func deSerializeJSON(data: NSData, completionHandler: (data: AnyObject!, error: NSError) -> Void){
        
        var parsedData: AnyObject!
        
        do{
            parsedData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
        } catch {
            print("error")
        }
        completionHandler(data: parsedData, error: NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey : "desc"]))
   
        
    }
    
    
    // build the query
    func getQueryBuilder (parameters : [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = ParseClient.Parse.scheme
        components.host = ParseClient.Parse.host
        components.path = "/\(ParseClient.Parse.apiVersion)/\(ParseClient.Parse.path)" + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        for (key, value) in parameters{
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
        
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
    
    func errorHandler(errorString : NSError){
        print(errorString.localizedDescription)
    }
    
    func noError() -> NSError{
        return NSError(domain: "No Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No Error"])
    }
}
