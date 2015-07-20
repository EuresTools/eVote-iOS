//
//  Poll.swift
//  eVote
//
//  Created by Björn Orri Saemundsson on 7/20/15.
//  Copyright (c) 2015 Eurescom. All rights reserved.
//

import UIKit

class Poll: NSObject {
   
    var title: String?
    var question: String?
    var select_min: Int?
    var select_max: Int?
    var options: [Option] = []
}

