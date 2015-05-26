//
//  PollViewControllerTableViewController.swift
//  eVote
//
//  Created by Björn Orri Saemundsson on 5/20/15.
//  Copyright (c) 2015 Eurescom. All rights reserved.
//

import UIKit
import SwiftyJSON
import M13Checkbox

class PollViewController: UITableViewController {
    
    var poll: Dictionary<String, JSON>?
    var code = ""
    var votes: Set<Int> = []
    @IBOutlet weak var queryLabel: UILabel!
    @IBOutlet var headerView: UITableViewHeaderFooterView!
    @IBOutlet weak var footerView: UITableViewHeaderFooterView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.frame.size.width = self.view.bounds.width
        
        let query = poll!["query"]!.stringValue
        
        queryLabel.text = query
        queryLabel.textAlignment = NSTextAlignment.Justified
        
        // Adjust the header view to fit the query text.
        queryLabel.sizeToFit()
        headerView.frame.size.height = queryLabel.frame.height + 16
        
        // Set the background color of the header.
        headerView.backgroundView = UIView(frame: headerView.bounds)
        headerView.backgroundView!.backgroundColor = UIColor.whiteColor()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let p = poll {
            let options = p["options"]!.arrayValue
            return options.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PollOptionTableViewCell", forIndexPath: indexPath) as! PollOptionTableViewCell
        if let p = poll {
            let options = p["options"]!.arrayValue
            let option = options[indexPath.row].stringValue
            cell.optionLabel.text = option
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let select = poll!["select"]!.intValue
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PollOptionTableViewCell
        
        // If this is a one choice poll, move the selection.
        if select == 1 {
            cell.checkBox.toggleCheckState()
            if votes.contains(indexPath.row) {
                votes.remove(indexPath.row)
            }
            else {
                votes.insert(indexPath.row)
            }
            for (index,c) in enumerate(tableView.visibleCells() as! [PollOptionTableViewCell]) {
                if c.checkBox.checkState.value == M13CheckboxStateChecked.value && c != cell {
                    if votes.contains(index) {
                        votes.remove(index)
                    }
                    else {
                        votes.insert(index)
                    }
                    c.checkBox.toggleCheckState()
                }
            }
        }
        else {
            // Prevent the user from selecting more options than allowed.
            var count = 0
            for cell in tableView.visibleCells() as! [PollOptionTableViewCell] {
                if cell.checkBox.checkState.value == M13CheckboxStateChecked.value {
                    count++
                }
            }
            if count < select || cell.checkBox.checkState.value == M13CheckboxStateChecked.value {
                if votes.contains(indexPath.row) {
                    votes.remove(indexPath.row)
                }
                else {
                    votes.insert(indexPath.row)
                }
                cell.checkBox.toggleCheckState()
            }
            else {
                // User tried to select more options than allowed.
                println("Can't select more options")
                alert("Not allowed", message: "You cannot select more than \(select) options.")
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func didPressSubmitButton(sender: AnyObject) {
        APIClient.submitVoteForCode(code, votes: Array(votes), completionHandler: {
            (request: NSURLRequest, response: NSURLResponse?, data: AnyObject?, error: NSError?) in
            let json = JSON(data!)
            let success = json["success"].boolValue
            let message = json["message"].stringValue
            if success {
                self.alert("Success", message: message)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                self.alert("Error", message: message)
            }
        })
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerView.frame.height
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerView.frame.height
    }
    
    func alert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
