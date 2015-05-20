//
//  APIClient.swift
//  eVote
//
//  Created by Björn Orri Saemundsson on 5/20/15.
//  Copyright (c) 2015 Eurescom. All rights reserved.
//

import UIKit
import Alamofire

class APIClient: NSObject {
   
    static let baseURL = "http://localhost:5000"
    static let voteURL = "\(baseURL)/vote"
    
    static func getPollForCode(code: String, completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        Alamofire.request(.GET, voteURL, parameters: ["code": code])
        .responseJSON(options: NSJSONReadingOptions.allZeros, completionHandler: completionHandler)
    }
}
