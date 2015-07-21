//
//  ViewController.swift
//  eVote
//
//  Created by Björn Orri Saemundsson on 5/20/15.
//  Copyright (c) 2015 Eurescom. All rights reserved.
//

import UIKit
import SwiftyJSON

class VoteCodeViewController: UIViewController {

    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tappedOutside:")
        self.view.addGestureRecognizer(tapGestureRecognizer)
        loadPassedToken()
    }
    
    func loadPassedToken() {
        if(self.isViewLoaded()) {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if let token = appDelegate.passedToken {
                self.codeField.text = token
                appDelegate.passedToken = nil
            }
        }
    }
    
    func tappedOutside(gesture: UITapGestureRecognizer) {
        // Dismiss the keyboard.
        codeField.resignFirstResponder()
    }
    
    @IBAction func didPressSubmitButton(sender: AnyObject) {
        let code = codeField.text
        APIClient.getPollForCode(code) {
            (request: NSURLRequest, response: NSURLResponse?, data: AnyObject?, error: NSError?) in
            
            if let _error = error {
                println("An error occurred!")
                println(_error)
                self.alert("Error", message: "An error occurred. Try again later.")
                return
            }
            
            let json = JSON(data!)
            let success = json["success"].boolValue
            if !success {
                // Check if we hit the auth filter.
                let status = json["status"].intValue
                if status == 401 {
                    self.alert("Error", message: "Invalid voting code")
                } else {
                    let error = json["error"]
                    let message = error["message"].stringValue
                    self.alert("Error", message: message)
                }
                return
            }
            let pollJSON = json["data"]
            let poll = self.pollFromJson(pollJSON)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let pollVC = storyboard.instantiateViewControllerWithIdentifier("PollViewController") as! PollViewController
            pollVC.poll = poll
            pollVC.code = code
            self.showViewController(pollVC, sender: nil)
            self.codeField.text = ""
        }
    }
    
    func alert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func pollFromJson(json: JSON) -> Poll {
        let poll = Poll()
        poll.title = json["title"].stringValue
        poll.question = json["question"].stringValue
        poll.select_min = json["select_min"].intValue
        poll.select_max = json["select_max"].intValue
        for optionJSON in json["options"].arrayValue {
            let option = Option()
            option.id = optionJSON["id"].intValue
            option.text = optionJSON["text"].stringValue
            poll.options.append(option)
        }
        return poll
    }
}
