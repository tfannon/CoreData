//
//  Bodypart.swift
//  CoreDataTests
//
//  Created by Tommy Fannon on 2/17/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import Foundation
import CoreData

@objc(Bodypart)
public class Bodypart: NSManagedObject {

    @NSManaged public var name: String
    @NSManaged public var exercises: NSSet

}
