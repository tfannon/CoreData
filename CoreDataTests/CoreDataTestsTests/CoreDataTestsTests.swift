//
//  CoreDataTestsTests.swift
//  CoreDataTestsTests
//
//  Created by Tommy Fannon on 2/17/15.
//  Copyright (c) 2015 Crazy8Dev. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import CoreDataTests

class CoreDataTestsTests: XCTestCase {
    
    var moc = NSManagedObjectContext()
    
    override func setUp() {
        super.setUp()

        var mmol = NSManagedObjectModel.mergedModelFromBundles(nil)
        var psc = NSPersistentStoreCoordinator(managedObjectModel: mmol!)
        var pstore = NSPersistentStore()
        pstore = psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil)!
        moc.persistentStoreCoordinator = psc
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /* Boss->Employee*  1->N
    *    Must make sure the relationship is marked as a ToMany in model and you are using an NSSet for the many
    */
    func testBossEmployeeRelationship() {
        var e: NSError?
        
        let boss = createEntity("Boss") as! Boss
        boss.name = "Chef"
        moc.save(&e)
        
        let emp1 = createEntity("Employee") as! Employee
        emp1.name = "Cartman"
        emp1.boss = boss
        moc.save(&e)
        
        //in-memory graph is updated
        XCTAssertEqual(1, boss.employees.count)
        
        //get at it from boss' employees
        var bosses = fetchEntities("Boss") as! [Boss]
        XCTAssertGreaterThan(bosses.count, 0, "Bosses not created")
        let testBoss = bosses[0]
        let bossEmployees = testBoss.employees
        XCTAssertEqual(bossEmployees.count, 1, "Boss employees not retrieved")
        
        //get at it from employees boss
        var employees = fetchEntities("Employee") as! [Employee]
        let testEmp = employees[0]
        XCTAssertNotNil(testEmp.boss, "Employee boss not found")
    }
    
    /* Boss->Employee*  1->N
    *    Must make sure the relationship is marked as a ToMany in model and you are using an NSSet for the many
    */
    func testSettingBossesEmployees() {
        var e: NSError?
        
        let boss = createEntity("Boss") as! Boss
        boss.name = "Chef"
        
        let emp1 = createEntity("Employee") as! Employee
        emp1.name = "Cartman"
        
        boss.addEmployee(emp1)
        moc.save(&e)
        
        //in-memory graph is updated!
        XCTAssertNotNil(emp1.boss, "Employee boss not found")
        
        //get at it from boss' employees
        var bosses = fetchEntities("Boss") as! [Boss]
        XCTAssertGreaterThan(bosses.count, 0, "Bosses not created")
        let testBoss = bosses[0]
        let bossEmployees = testBoss.employees
        XCTAssertEqual(bossEmployees.count, 1, "Boss employees not retrieved")
        
        //get at it from employees boss
        var employees = fetchEntities("Employee") as! [Employee]
        let testEmp = employees[0]
        XCTAssertNotNil(testEmp.boss, "Employee boss not found")
    }
    
    
    /* if you want deletion of the boss to delete employees, you must make the ToMany
    relationship to Employee cascase on delete in the model  */
    func testDeleteBossDeletesEmployees() {
        // setup item
        var e: NSError?
        
        let boss = createEntity("Boss") as! Boss
        boss.name = "Chef"
        moc.save(&e)
        
        let emp1 = createEntity("Employee") as! Employee
        emp1.name = "Cartman"
        emp1.boss = boss
        moc.save(&e)
        
        moc.deleteObject(boss)
        
        var employees = fetchEntities("Employee") as! [Employee]
        XCTAssertEqual(employees.count, 0, "Employee was not deleted")
    }
    
    /* deleting an employee should not delete the boss.  you must make the
    ToOne relationship to Boss nullify on delete */
    func testDeleteEmployeeDoesNotDeleteBoss() {
        // setup item
        var e: NSError?
        
        let boss = createEntity("Boss") as! Boss
        boss.name = "Chef"
        moc.save(&e)
        
        let emp1 = createEntity("Employee") as! Employee
        emp1.name = "Cartman"
        emp1.boss = boss
        moc.save(&e)
        
        moc.deleteObject(emp1)
        
        var employees = fetchEntities("Employee") as! [Employee]
        XCTAssertEqual(employees.count, 0, "Employee was not deleted")
        
        var bosses = fetchEntities("Boss") as! [Boss]
        XCTAssertEqual(1, bosses.count, "Boss should not have been deleted")
        var testBoss = bosses[0]
        XCTAssertEqual(0, testBoss.employees.count)
    }
    
    
    func testRemoveEmployeeDeletesEmployee() {
        var e: NSError?
        let boss = createEntity("Boss") as! Boss
        boss.name = "Chef"
        moc.save(nil)
        
        let emp1 = createEntity("Employee") as! Employee
        emp1.name = "Cartman"
        emp1.boss = boss
        moc.save(&e)
        
        boss.removeEmployee(emp1)
        moc.save(&e)
        
        //refetch the boss.  should not have any employees
        var bosses = fetchEntities("Boss") as! [Boss]
        var testBoss = bosses[0]
        XCTAssertEqual(testBoss.employees.count, 0, "Employee was not deleted")
        
        
        //it appears the removing employee from collection orphans it.
        //refetch the employees.  should not have any
        var employees = fetchEntities("Employee") as! [Employee]
        //XCTAssertEqual(employees.count, 0, "Employee was not deleted")
    }
    
    func testFetchEntities() {
        var e: NSError?
        let boss = createEntity("Boss") as! Boss
        boss.name = "Chef"
        moc.save(&e)
        var results = fetchEntities("Boss") as! [Boss]
        XCTAssertEqual(1, results.count, "Should have fetched 1 boss")
    }
    
    /*
    func createEntity<T where T : NSManagedObject>(name : String) {
    var entity = NSEntityDescription.entityForName(name, inManagedObjectContext: moc)
    var e: NSError?
    
    let boss = T(entity: entity!, insertIntoManagedObjectContext: moc)
    //boss.name = "Chef"
    moc.save(&e)
    }
    */
    
    
    func createEntity(name : String) -> NSManagedObject? {
        var entity = NSEntityDescription.entityForName(name, inManagedObjectContext: moc)
        var e: NSError?
        var obj : NSManagedObject
        switch (name) {
        case "Boss" :
            obj = Boss(entity: entity!, insertIntoManagedObjectContext: moc)
        case "Employee" :
            obj = Employee(entity: entity!, insertIntoManagedObjectContext: moc)
        case "Bodypart" :
            obj = Bodypart(entity: entity!, insertIntoManagedObjectContext: moc)
        case "Exercise" :
            obj = Exercise(entity: entity!, insertIntoManagedObjectContext: moc)
        default:
            println ("Bad entity type:\(name)")
            abort()
        }
        return obj
    }
    
    func fetchEntities(name : String) -> [NSManagedObject] {
        let request = NSFetchRequest(entityName: name)
        var e : NSError?
        if let results = moc.executeFetchRequest(request, error: &e) as? [NSManagedObject] {
            return results
        } else {
            println("fetch error: \(e!.localizedDescription)")
            abort();
        }
    }
    
    func testBodypartToExercise() {
        var e: NSError?
        
        let bodypart = createEntity("Bodypart") as! Bodypart
        bodypart.name = "Chest"
        moc.save(&e)
        
        let exercise1 = createEntity("Exercise") as! Exercise
        exercise1.name = "Bench Press"
        moc.save(&e)
        
        let exercise2 = createEntity("Exercise") as! Exercise
        exercise2.name = "Smith Machine Press"
        moc.save(&e)
    }
}

