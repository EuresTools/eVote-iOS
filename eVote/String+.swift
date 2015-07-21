//
//  String+.swift
//  eVote
//
//  Created by Björn Orri Saemundsson on 7/21/15.
//  Copyright (c) 2015 Eurescom. All rights reserved.
//

import Foundation

extension String {
    
    func contains(find: String) -> Bool {
        return self.rangeOfString(find) != nil
    }
    
    func startsWith(prefix: String) -> Bool {
        return self.rangeOfString(prefix)?.startIndex == self.startIndex
    }
    
    func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    subscript (i: Int) -> Character {
        get {
            let index = advance(startIndex, i)
            return self[index]
        }
    }
}