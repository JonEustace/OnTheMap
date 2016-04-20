//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by iMac on 2016-03-01.
//  Copyright © 2016 iMac. All rights reserved.
//

import Foundation

struct StudentInformation{
    
    let dateCreated, firstName, lastname, mapString, objectID, updatedAt, uniqueKey, mediaURL : String
    let latitude, longitude : Float
  
   
    init(studentDictionary : [String: AnyObject]){
        
        self.dateCreated = studentDictionary["createdAt"] as! String
        self.firstName = studentDictionary["firstName"] as! String
        self.lastname = studentDictionary["lastName"] as! String
        self.mapString = studentDictionary["mapString"] as! String
        self.objectID = studentDictionary["objectId"] as! String
        self.updatedAt = studentDictionary["updatedAt"] as! String
        self.latitude = studentDictionary["latitude"] as! Float
        self.longitude = studentDictionary["longitude"] as! Float
        self.uniqueKey = studentDictionary["uniqueKey"] as! String
        self.mediaURL = studentDictionary["mediaURL"] as! String
        
        
    }
    
}

