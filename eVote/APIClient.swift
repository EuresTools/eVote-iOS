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
    
    #if (arch(i386) || arch(x86_64)) && os(iOS)
    static var baseURL = "http://localhost:5000"
    #else
    static var baseURL = "http://evoteapi.herokuapp.com"
    #endif
    static let pollURL = "\(baseURL)/polls"
    
    static func getPollForCode(code: String, completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        Alamofire.request(.GET, pollURL, parameters: ["code": code])
        .responseJSON(options: NSJSONReadingOptions.allZeros, completionHandler: completionHandler)
    }
    
    static func submitVoteForCode(code: String, votes: [Int], pollId: Int, completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        Alamofire.request(.POST, "\(pollURL)/\(pollId)/votes", parameters: ["code": code, "options": votes], encoding: .JSON)
        .responseJSON(options: NSJSONReadingOptions.allZeros, completionHandler: completionHandler)
    }
}
