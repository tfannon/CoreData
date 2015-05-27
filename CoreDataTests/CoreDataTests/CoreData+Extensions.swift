//
//  Extensions.swift
//  NameSpaceTest
//
//  Created by Tommy Fannon on 2/17/15.
//  Copyright (c) 2015 Dirk Fabisch. All rights reserved.
//

import Foundation


public extension Boss {

    public func addEmployee(value : Employee) {
        var items = self.mutableSetValueForKey("employees")
        items.addObject(value)
    }
    
    public func removeEmployee(value : Employee) {
        var items = self.mutableSetValueForKey("employees")
        items.removeObject(value)
    }
}
