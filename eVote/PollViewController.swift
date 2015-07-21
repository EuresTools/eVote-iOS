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
import MBProgressHUD

class PollViewController: UITableViewController {
    
    var poll: Poll?
    var code = ""
    var votes: Set<Option> = []
    @IBOutlet weak var queryLabel: UILabel!
    @IBOutlet weak var selectionLabel: UILabel!
    @IBOutlet var headerView: UITableViewHeaderFooterView!
    @IBOutlet weak var footerView: UITableViewHeaderFooterView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.frame.size.width = self.view.bounds.width
        
        let title = poll!.title
        self.title = title
        // Don't truncate the title in the navigation bar.
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .Center
        titleLabel.text = title
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.font = UIFont(name: "Helvetica-Bold", size: 17.0)
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.adjustsFontSizeToFitWidth = true
        self.navigationItem.titleView = titleLabel
        
        let query = poll!.question
        
        queryLabel.text = query
        queryLabel.textAlignment = NSTextAlignment.Justified
        
        let min = poll!.select_min!
        let max = poll!.select_max!
        let selectionString = min == max ? "\(min)" : "\(min) - \(max)"
        let optionString = min == 1 && max == 1 ? "option" : "options"
        
        selectionLabel.text = "Select \(selectionString) \(optionString)"
        
        // Adjust the header view to fit the query text.
        queryLabel.sizeToFit()
        headerView.frame.size.height = queryLabel.frame.height + 16
        
        // Set the background color of the header and footer.
        headerView.backgroundView = UIView(frame: headerView.bounds)
        headerView.backgroundView!.backgroundColor = UIColor.whiteColor()
        footerView.backgroundView = UIView(frame: footerView.bounds)
        footerView.backgroundView!.backgroundColor = UIColor.whiteColor()
        
        headerView.backgroundView!.alpha = 0.9
        footerView.backgroundView!.alpha = 0.9
        
        // Add borders to header and footer.
        let headerBorder = CALayer()
        let headerFrame = headerView.frame
        headerBorder.frame = CGRect(x: headerFrame.minX, y: headerFrame.maxY, width: headerFrame.width, height: 1.0)
        headerBorder.backgroundColor = UIColor.lightGrayColor().CGColor
        headerView.layer.addSublayer(headerBorder)
        
        let footerBorder = CALayer()
        let footerFrame = footerView.frame
        footerBorder.frame = CGRect(x: footerFrame.minX, y: footerFrame.minY, width: footerFrame.width, height: 1.0)
        footerBorder.backgroundColor = UIColor.lightGrayColor().CGColor
        footerView.layer.addSublayer(footerBorder)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poll!.options.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PollOptionTableViewCell", forIndexPath: indexPath) as! PollOptionTableViewCell
        let option = poll!.options[indexPath.row]
        cell.optionLabel.text = option.text
        if votes.contains(option) {
            cell.checkBox.checkState = M13CheckboxStateChecked
        } else {
            cell.checkBox.checkState = M13CheckboxStateUnchecked
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let select = poll!.select_max!
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PollOptionTableViewCell
        let option = poll!.options[indexPath.row]
        
        // If this is a one choice poll, move the selection.
        if select == 1 {
            if votes.contains(option) {
                votes.remove(option)
            }
            else {
                votes.removeAll(keepCapacity: false)
                votes.insert(option)
            }
        }
        else {
            // Prevent the user from selecting more options than allowed.
            let count = votes.count
            if votes.contains(option) {
                votes.remove(option)
            }
            else if(count < select) {
                votes.insert(option)
            }
            else {
                // User tried to select more options than allowed.
                println("Can't select more options")
                let optionStr = select == 1 ? "option" : "options"
                alert("Not allowed", message: "You cannot select more than \(select) \(optionStr).")
            }
        }
        updateUI()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func updateUI() {
        self.tableView.reloadData()
    }
    
    @IBAction func didPressSubmitButton(sender: AnyObject) {
        MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
        APIClient.submitVoteForCode(code, votes: Array(votes), completionHandler: {
            (request: NSURLRequest, response: NSURLResponse?, data: AnyObject?, error: NSError?) in
            MBProgressHUD.hideHUDForView(self.tableView, animated: true)
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
            let alert = UIAlertController(title: "Success", message: "Your vote has been submitted.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                (_) in
                self.navigationController!.popViewControllerAnimated(true)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
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
