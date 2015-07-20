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
    
    static var defaultBaseURL = "http://localhost:82"
//    static let pollURL = "\(APIClient.getBaseURL())/poll"
//    static let voteURL = "\(APIClient.getBaseURL())/vote"
    
    static func getBaseURL() -> String {
        var baseURL = NSUserDefaults.standardUserDefaults().valueForKey("baseURL") as! String?
        if baseURL == nil {
            baseURL = defaultBaseURL
        }
        return baseURL!
    }
    
    static func getPollForCode(code: String, completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        Alamofire.request(.GET, "\(getBaseURL())/v1/poll/get", parameters: ["token": code])
        .responseJSON(options: NSJSONReadingOptions.allZeros, completionHandler: completionHandler)
    }
    
    static func submitVoteForCode(code: String, votes: [Option], completionHandler: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> Void) {
        
        let urlString = "\(getBaseURL())/v1/vote/submit"
        let tempURLRequest = NSURLRequest(URL: NSURL(string: urlString)!)
        let URLRequest = ParameterEncoding.URL.encode(tempURLRequest, parameters: ["token": code])
        let voteIDs = votes.map({option in option.id!})
        let bodyRequest = ParameterEncoding.JSON.encode(tempURLRequest, parameters: ["options": voteIDs])
        
        let compositeRequest = URLRequest.0.mutableCopy() as! NSMutableURLRequest
        compositeRequest.HTTPMethod = "POST"
        compositeRequest.HTTPBody = bodyRequest.0.HTTPBody
        compositeRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        Alamofire.request(compositeRequest).responseJSON(options: NSJSONReadingOptions.allZeros, completionHandler: completionHandler)
    }
}
