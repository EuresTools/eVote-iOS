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
    var options: [String] = []
    var optionIds: [Int] = []
    var code = ""
    var votes: Set<Int> = []
    @IBOutlet weak var queryLabel: UILabel!
    @IBOutlet var headerView: UITableViewHeaderFooterView!
    @IBOutlet weak var footerView: UITableViewHeaderFooterView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.frame.size.width = self.view.bounds.width
        
        let query = poll!["question"]!.stringValue
        
        queryLabel.text = query
        queryLabel.textAlignment = NSTextAlignment.Justified
        
        // Adjust the header view to fit the query text.
        queryLabel.sizeToFit()
        headerView.frame.size.height = queryLabel.frame.height + 16
        
        // Set the background color of the header and footer.
        headerView.backgroundView = UIView(frame: headerView.bounds)
        headerView.backgroundView!.backgroundColor = UIColor.whiteColor()
        footerView.backgroundView = UIView(frame: footerView.bounds)
        footerView.backgroundView!.backgroundColor = UIColor.whiteColor()
        
        if let p = poll {
            let jsoptions = p["options"]!.arrayValue
            for option in jsoptions {
                options.append(option["option"].stringValue)
                optionIds.append(option["id"].intValue)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PollOptionTableViewCell", forIndexPath: indexPath) as! PollOptionTableViewCell
        if let p = poll {
            let option = options[indexPath.row]
            cell.optionLabel.text = option
            if votes.contains(optionIds[indexPath.row]) {
                cell.checkBox.checkState = M13CheckboxStateChecked
            }
            else {
                cell.checkBox.checkState = M13CheckboxStateUnchecked
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let select = poll!["select_max"]!.intValue
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PollOptionTableViewCell
        
        // If this is a one choice poll, move the selection.
        if select == 1 {
            if votes.contains(optionIds[indexPath.row]) {
                votes.remove(optionIds[indexPath.row])
            }
            else {
                votes.removeAll(keepCapacity: false)
                votes.insert(optionIds[indexPath.row])
            }
        }
        else {
            // Prevent the user from selecting more options than allowed.
            let count = votes.count
            if count < select || votes.contains(optionIds[indexPath.row]) {
                if votes.contains(optionIds[indexPath.row]) {
                    votes.remove(optionIds[indexPath.row])
                }
                else {
                    votes.insert(optionIds[indexPath.row])
                }
            }
            else {
                // User tried to select more options than allowed.
                println("Can't select more options")
                alert("Not allowed", message: "You cannot select more than \(select) options.")
            }
        }
        updateUI()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func updateUI() {
        self.tableView.reloadData()
    }
    
    @IBAction func didPressSubmitButton(sender: AnyObject) {
        APIClient.submitVoteForCode(code, votes: Array(votes), pollId: poll!["id"]!.intValue, completionHandler: {
            (request: NSURLRequest, response: NSURLResponse?, data: AnyObject?, error: NSError?) in
            let minimum = self.poll!["select_min"]!.intValue
            if self.votes.count < minimum {
                var options = "options"
                if minimum == 1 {
                    options = "option"
                }
                self.alert("Error", message: "You must select at least \(minimum) \(options).")
            }
            else {
                let json = JSON(data!)
                let status = json["status"].string
                let success = status == "success"
                if success {
                    let alert = UIAlertController(title: "Success", message: "Vote submitted successfully.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                        (_) in
                        self.navigationController!.popViewControllerAnimated(true)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else {
                    var message = "Something went wrong."
                    if let error = json["data"].dictionary?["code"]?.string {
                        message = error
                    }
                    else if let error = json["data"].dictionary?["options"]?.string {
                        message = error
                    }
                    self.alert("Error", message: message)
                }
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
