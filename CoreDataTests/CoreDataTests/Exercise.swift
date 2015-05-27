//
//  Exercise.swift
//  CoreDataTests
//
//  Created by Tommy Fannon on 2/17/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation
import CoreData

@objc(Exercise)
public class Exercise: NSManagedObject {

    @NSManaged public var name: String
    @NSManaged public var bodyparts: NSSet

}
