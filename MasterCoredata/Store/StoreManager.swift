//
//  StoreManager.swift
//  MasterCoredata
//
//  Created by Hosamane, Vinay K N on 11/05/21.
//

import Foundation
import CoreData

class StoreManager {
    lazy var coredataPersistentContainer = CoredataStorePersistentContainer()
    lazy var currentContext = coredataPersistentContainer.persistentContainer.viewContext
    
    func execute() {
        // print the sqlite location
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print(paths[0])
    
        
        let person = Person(context: currentContext)
        // car managed object
        let car = Car(context: currentContext)
        car.maker = "Maruthi"
        car.model = "Waganor"
        car.owner = person
        
        person.firstName = "Vinay"
        person.lastName = "Hosamane"
        person.addToCars(car)
        
        coredataPersistentContainer.saveContext()
        
        // fetch some data
        let fetch: NSFetchRequest<Person> = Person.fetchRequest()
        
        do {
            let _ = try currentContext.fetch(fetch)
            //print(fetchedValue)
        } catch(let error) {
            print(error)
        }
    }
    
}
