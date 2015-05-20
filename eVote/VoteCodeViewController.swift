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
                self.alert("Error", message: "An error occurred. Try again later.")
                return
            }
            
            let json = JSON(data!)
            if let success = json["success"].bool {
                if success {
                    println("Success")
                    let poll = json["poll"].dictionaryValue
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    var pollVC = storyboard.instantiateViewControllerWithIdentifier("PollViewController") as! PollViewController
                    pollVC.poll = poll
                    self.showViewController(pollVC, sender: nil)
                }
                else {
                    println("Failure")
                    let message = json["message"].stringValue
                    self.alert("Error", message: message)
                }
            }
        }
    }
    
    func alert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
