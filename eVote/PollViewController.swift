//
//  PollViewControllerTableViewController.swift
//  eVote
//
//  Created by Björn Orri Saemundsson on 5/20/15.
//  Copyright (c) 2015 Eurescom. All rights reserved.
//

import UIKit
import SwiftyJSON

class PollViewController: UITableViewController {
    
    var poll: Dictionary<String, JSON>?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        println("There should be 1 section")
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let p = poll {
            let options = p["options"]!.arrayValue
            println("There should be \(options.count) cells")
            return options.count
        }
        println("There should be 0 cells")
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        cell.textLabel?.text = "Test"
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
}
