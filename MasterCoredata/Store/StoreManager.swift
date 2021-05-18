//
//  StoreManager.swift
//  MasterCoredata
//
//  Created by Hosamane, Vinay K N on 11/05/21.
//

import Foundation
import CoreData
import Combine

class StoreManager {

    lazy var coredataPersistentContainer = CoredataStorePersistentContainer()
    lazy var currentContext = coredataPersistentContainer.persistentContainer.viewContext
    
    var cancellables = Set<AnyCancellable>()
    
    func execute() {
        printSQLStoreFileDirectoryPath()

        //insertDataInChildContext()
        
        //insertRecordWithEntityDescription()
        
        //contextInGlobalThread()
        
        sharingManagedObjectByObjectId()
    }
    
    func insertDataInsideContextsQueue() {
        currentContext.perform {
            print("--- Thread --- \(Thread.current)")
            let person = Person(context: self.currentContext)
            // car managed object
            let car = Car(context: self.currentContext)
            car.maker = "Kia"
            car.model = "Seltos"
            car.addOwner(person)
            
            person.firstName = "Vinay"
            person.lastName = "Hosamane"
            person.addToCars(car)
            self.synchronize(self.currentContext)
        }
    }
    
    func insertingDataInGloabalThread() {
        // we get thread signal trap for this.
        DispatchQueue.global(qos: .background).async {
            print("--- Thread --- \(Thread.current)")
            let person = Person(context: self.currentContext)
            // car managed object
            let car = Car(context: self.currentContext)
            car.maker = "Kia"
            car.model = "Seltos"
            car.addOwner(person)
            
            person.firstName = "Vinay"
            person.lastName = "Hosamane"
            person.addToCars(car)
            
            self.currentContext.perform {
                print("--- Thread --- \(Thread.current)")
                do {
                    try self.currentContext.save()
                } catch (let error) {
                    print(error)
                }
            }
        }
        
        // crashes application
        DispatchQueue.global().async {
            // let's try to access main contet here.
            // we can execute some db operations here
            let fetchRequest = NSFetchRequest<Car>(entityName: "Car")
            fetchRequest.predicate = NSPredicate(format: "maker == %@", "Kia")
            
            do {
                let cars = try self.currentContext.fetch(fetchRequest)
                print(cars)
            } catch(let error) {
                print(error)
            }
        }
    }
    
    func printSQLStoreFileDirectoryPath() {
        // print the sqlite location
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print(paths[0])
    }
    
    func simpleInsert() {
        let person = Person(context: currentContext)
        // car managed object
        let car = Car(context: currentContext)
        car.maker = "Maruthi"
        car.model = "Waganor"
        car.addOwner(person)
        
        person.firstName = "Vinay"
        person.lastName = "Hosamane"
        person.addToCars(car)
        
        synchronize(currentContext)
    }
    
    func insertRecordWithEntityDescription() {
        guard let personEntity = NSEntityDescription.entity(forEntityName: "Person", in: currentContext), let carEntity = NSEntityDescription.entity(forEntityName: "Car", in: currentContext) else {
            return
            
        }
        print(personEntity.relationships(forDestination: carEntity))
        
        let personManagedObject = NSManagedObject(entity: personEntity, insertInto: currentContext) as! Person
        personManagedObject.firstName = "Me"
        personManagedObject.lastName = "Something"
        
        let carManageObject = NSManagedObject(entity: carEntity, insertInto: currentContext) as! Car
        carManageObject.addOwner(personManagedObject)
        carManageObject.maker = "Maruthi"
        carManageObject.model = "Swift"
        
        personManagedObject.addToCars(carManageObject)
        
        didMergeNotificationPublisher(for: personManagedObject, in: currentContext).sink { (person) in
            print(person)
        }.store(in: &cancellables)
        
        synchronize(currentContext)
    }
    
    func fetchDataInBackgroundContet() {
        coredataPersistentContainer.persistentContainer.performBackgroundTask { (backgroundContext) in
            // we can execute some db operations here
            let fetchRequest = NSFetchRequest<Car>(entityName: "Car")
            fetchRequest.predicate = NSPredicate(format: "maker == %@", "Kia")
            
            do {
                let cars = try backgroundContext.fetch(fetchRequest)
                print(cars)
            } catch(let error) {
                print(error)
            }
        }
    }
    
    func insertDataInChildContext() {
        // this child contet belongs only to this queue
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = self.currentContext // setting parent contet, internally set's persistent co-ordinator to child context.
        //childContext.automaticallyMergesChangesFromParent = true  // this did not work
       
        childContext.perform {
            // since this is a private queue, we can only access this thread using one of it's methods.
            print("--- Thread ---\(Thread.current)")
            let personP = Person(context: childContext)
            // car managed object
            let carP = Car(context: childContext)
            carP.maker = "Kia"
            carP.model = "Sonet"
            carP.addOwner(personP)
            
            personP.firstName = "Varun"
            personP.lastName = "Gupta"
            personP.addToCars(carP)
        }
        
        // let's save changes to private contet
        self.synchronize(childContext)
        
//        // let's make sure, private contet changes are merged to main contet
        synchronize(currentContext)
    }
    
    // this is used when parent / child contexts saving managed object. Child context saves managed object, parent will merge that child context changes to main context.
    // then this notification would get triggered.
    // here context, it should be context for which this managed object is registered. Using object id, load managed object into target context.
    @nonobjc
    func didMergeNotificationPublisher<T: NSManagedObject, C: NSManagedObjectContext>(for managedObject: T, in context: C) -> AnyPublisher<T, Never> {
        let notificationName = NSManagedObjectContext.didSaveObjectIDsNotification
        return NotificationCenter.default.publisher(for: notificationName, object: context)
            .compactMap { (notification) -> T? in
                if let updated = notification.userInfo?[NSInsertedObjectIDsKey] as? Set<NSManagedObjectID>,
                   updated.contains(managedObject.objectID),
                   let updatedObject = context.object(with: managedObject.objectID) as? T {
                    return updatedObject
                } else {
                    return nil
                }
            }.eraseToAnyPublisher()
    }
    
    func contextInGlobalThread() {
        DispatchQueue.global().async {
            // let's create a new context
            // now this context will have it's own quque in this thread, so it should not be used in different thread.
            let internalContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            internalContext.persistentStoreCoordinator = self.currentContext.persistentStoreCoordinator
            
            internalContext.perform {
                let person = Person(context: internalContext)
                // car managed object
                let car = Car(context: internalContext)
                car.maker = "Honda"
                car.model = "City"
                car.addOwner(person)
                
                person.firstName = "Pavan"
                person.lastName = "Kumar"
                person.addToCars(car)
            }
            self.synchronize(internalContext)
        }
    }
    
    func sharingManagedObjectByObjectId() {
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        fetchRequest.predicate = NSPredicate(format: "firstName == %@", "Reshma")
        
        // always make sure this managed object is already saved in the store as a record, else it won't update the values when the object is not found.
        // good thing is if the object is not loaded to persistent container, it fetches and keeps in in-memory.
        var personId: NSManagedObjectID? = nil
        
        do {
            let persons = try currentContext.fetch(fetchRequest)
            personId = persons.first?.objectID
            print(persons)
        } catch(let error) {
            print(error)
        }

        print("---- Inside main context ---\(String(describing: personId))") // unique object id of person
        
        // let's create a background thread.
        DispatchQueue.global().async {
            guard let personId = personId else {
                return
            }
            // let's create a new background context
            let tempContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType) // private queue, should use one of perform or performAndWait to execute block
            tempContext.persistentStoreCoordinator = self.currentContext.persistentStoreCoordinator // assign persistent co-ordinator to temp context, so that when we save changes to this context, it will also save it to main context.
            print("--Inside Temp Context--\(String(describing: personId))")
            
            tempContext.performAndWait {
                //let person = tempContext.object(with: personId) as? Person
                // let's get the copy of person object from main context
                do {
                    // this api to check the existence might be slow, use object(personId)
                    guard let person = try tempContext.existingObject(with: personId) as? Person else {
                        return
                    }
                    person.firstName = "Sandy"
                    person.lastName = "Man"
                    
                    let car = Car(context: tempContext)
                    car.maker = "Renault"
                    car.model = "Kiger"
                    car.addOwner(person)
                    
                    person.addToCars(car)
                    
                    // save changes to temp context
                    
                    // on save it updates the previous values of person object in store.
                    self.synchronize(tempContext)
                } catch let error {
                    print(error)
                    return
                }
            }
        }
        
        synchronize(currentContext)
    }
    
    func synchronize(_ context: NSManagedObjectContext) {
            context.performAndWait {
                if context.hasChanges {
                    // it runs this code in the thread this contet is associated with.
                    do {
                        try context.save()
                    } catch (let error) {
                        print("Error in saving context to persistent store -- \(error)")
                        
                        // let's prinnt the callstack
                        for symbol in Thread.callStackSymbols {
                            print(" > \(symbol)")
                        }
                    }
                }
            }
    }

}
