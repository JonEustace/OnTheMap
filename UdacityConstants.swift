//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by iMac on 2016-02-25.
//  Copyright © 2016 iMac. All rights reserved.
//

import Foundation

extension UdacityClient{

    struct Facebook{
        
        static let FacebookAppID = "365362206864879"
        
       
    }
    
    
    struct Udacity{
        //MARK: API Key
        static let ApiKey : String = ""
        
        //MARK: URLs
    
        static let ApiScheme = "https"
        static let ApiHost = "udacity.com"
        static let ApiPath = "api"
        
    }
}

extension ParseClient{
    struct Parse{
        static let appIDValue = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApiKeyValue = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        static let ApiKey = "X-Parse-REST-API-KEY"
        static let AppId = "X-Parse-Application-Id"

        /*MARK: URLs*/
        static let scheme = "https"
        static let host = "api.parse.com"
        static let apiVersion = "1"
        static let path = "classes/StudentLocation"
        
    }
}