//
//  Students.swift
//  OnTheMap
//
//  Created by iMac on 2016-03-01.
//  Copyright © 2016 iMac. All rights reserved.
//

import Foundation

struct Students{
    var students : [StudentInformation]
    
    static let sharedInstance = Students()
    
    init() {
        
        
        self.students = [StudentInformation]()
    }
}