//
//  StudentInformationCollection.swift
//  OnTheMap
//
//  Created by iMac on 2016-04-15.
//  Copyright © 2016 iMac. All rights reserved.
//

import Foundation

class StudentInformationCollection {

    var locationz = [[String:AnyObject]]()
    var locationStructs = [StudentInformation]()
    
    static var sharedInstance = StudentInformationCollection()
    
    
}