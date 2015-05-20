//
//  ViewController.swift
//  eVote
//
//  Created by Björn Orri Saemundsson on 5/20/15.
//  Copyright (c) 2015 Eurescom. All rights reserved.
//

import UIKit

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
        println(code)
    }
}

