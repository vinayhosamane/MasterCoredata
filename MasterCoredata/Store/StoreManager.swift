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
        // prints sqlite store location inside application sandbox.
        printSQLStoreFileDirectoryPath()

        // 1. Insert records inside main thread context's queue.
        //insertDataInsideContextsQueue()
        
        // 2. Try to access main thread context inside global thread. (app crashes)
        //insertingDataInGloabalThread()
        
        // 3. Simple insert using managed obbject model and synchronise data using main thread contet.
        //simpleInsert()
        
        // 4. If we don't have models subclassed by NSManagedObject, then we should let the persistent store container to map the managed object model using entity description. This is another way of insertinng records to table.
        //insertRecordWithEntityDescription()
        
        // 5. We can use private context created by persistent container. We don't have to create a new private context.
        // using this, we can add or fetch new records.
        //fetchDataInBackgroundContext()
        
        // 6. To solve using of of main thread context inside different thread, we can use parent/child contexts.
        // here we will create a new private context inside that thread. So that the private contexts queue is owned by that thread.
        // use executor methods like `perform` (async) or `performAndWait` (sync), this applies onlt to that thread.
        // if you have set the persistent co-ordinator of child context to parent, on save on child context would automatically access parent's co-ordinator and merges chages.
        //insertingDataInGloabalThread()
        
        // 7.
        
    }
    
    func printSQLStoreFileDirectoryPath() {
        // print the sqlite location
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        if !paths.isEmpty {
            print(paths[0])
        }
    }

}

// MARK: Simple Insert using auto generated managed model subclassed models and NSEntityDescription
extension StoreManager {

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
        // just printing relationships
        print(personEntity.relationships(forDestination: carEntity))
        
        let personManagedObject = NSManagedObject(entity: personEntity, insertInto: currentContext) as! Person
        personManagedObject.firstName = "Me"
        personManagedObject.lastName = "Something"
        
        let carManageObject = NSManagedObject(entity: carEntity, insertInto: currentContext) as! Car
        carManageObject.addOwner(personManagedObject)
        carManageObject.maker = "Maruthi"
        carManageObject.model = "Swift"
        
        personManagedObject.addToCars(carManageObject)
        
        // trying out some data change or update notifications
        didMergeNotificationPublisher(for: personManagedObject, in: currentContext).sink { (person) in
            print(person)
        }.store(in: &cancellables)
        
        synchronize(currentContext)
    }
    
}

// MARK: delete records
extension StoreManager {

    func deleteObjects() {
        //let personEntityDescription = NSEntityDescription.entity(forEntityName: "Person", in: currentContext)
        
        // if you don't provide type 'NSFetchRequest<Person>', have you loaded entity model? error / crash happens.
        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "firstName = %@", "Vinay")
        
        // https://developer.apple.com/forums/thread/70919
        // be careful with delete rule provided to relation..if you have a inverse relationship and one has nullify and other has cascade, then the query would fail to delete records.
        let deleteBatchRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            // you can either create dleete batch transaction or fetch all records and then delete them one by one as required.
            // currentContext.delete(<managed-object>)
            try currentContext.execute(deleteBatchRequest)
        } catch let error {
            print(error)
        }
    }

}

// MARK: Usage of `perform` and `PerformAndWait`
extension StoreManager {

    func insertDataInsideContextsQueue() {
        // calling `perform` on the context, executes this block of code asynchronously.
        // remeber this code is still getting executed in the current main thread queue.
        currentContext.perform { [weak self] in
            print("--- Thread --- \(Thread.current)")
            guard let context = self?.currentContext else {
                return
            }
            let person = Person(context: context)
            // car managed object
            let car = Car(context: context)
            car.maker = "Kia"
            car.model = "Seltos"
            car.addOwner(person)
            
            person.firstName = "Vinay"
            person.lastName = "Hosamane"
            person.addToCars(car)
            self?.synchronize(context)
        }
    }

    func fetchDataInBackgroundContext() {
        coredataPersistentContainer.persistentContainer.performBackgroundTask { (backgroundContext) in
            // we can execute some db operations here
            
            // this code is executed in a private context queue. So that it won't block Ui queue.
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

}

// MARK: App crash code (main thread context used inside non-main thread)
extension StoreManager {

    func insertingDataInGloabalThread() {
        // we get thread signal trap for this.
        DispatchQueue.global(qos: .background).async {
            print("--- Thread --- \(Thread.current)")
            let person = Person(context: self.currentContext)
            // car managed object
            
            // we should be careful while accessing the contet which is created on different thread.
            // here current context is created on main thread. We are tryinng to use this context in background thread.
            // this will crash the app.
            let car = Car(context: self.currentContext)
            car.maker = "Kia"
            car.model = "Seltos"
            car.addOwner(person)
            
            person.firstName = "Vinay"
            person.lastName = "Hosamane"
            person.addToCars(car)
            
            // this code will be executed in the context's thread, which is main thread.
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
                // accessing main thread context will crash the app.
                let cars = try self.currentContext.fetch(fetchRequest)
                print(cars)
            } catch(let error) {
                print(error)
            }
        }
    }

}

// MARK: Using child context inside non-main thread.
extension StoreManager {

    // here you don't have to merge changes to main context
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
    
    // here you should merge child context changes to main contet
    func insertDataInChildContext() {
        // this child contet belongs only to this queue
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = self.currentContext // setting parent context
        //childContext.automaticallyMergesChangesFromParent = true  // this did not work
       
        // usually child contex's will not have access to persistent-co-ordinator, because of that they can not save data directly to database.
        childContext.perform {
            // since this is a private queue, we can only access this thread using one of it's methods.
            print("--- Thread ---\(Thread.current)")
            let personP = Person(context: childContext)
            // car managed object
            let carP = Car(context: childContext)
            carP.maker = "Kia"
            carP.model = "Sonet2"
            carP.addOwner(personP)
            
            personP.firstName = "Varun"
            personP.lastName = "Gupta"
            personP.addToCars(carP)
        }
        
        // let's save changes to private contet
        self.synchronize(childContext)
        
        // since we have just set the parent, we have make sure we push child context changes to parent context.
        // let's make sure, private context changes are merged to main context
        synchronize(currentContext)
    }

}

// MARK: Sharing main context managed object model with background thread child context.
extension StoreManager {

    func sharingManagedObjectByObjectId() {
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        fetchRequest.predicate = NSPredicate(format: "firstName == %@", "Sandy")
        
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
                    car.model = "Kiger2"
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

    }

}

// MARK: ManagedObjectModel change notifications.
extension StoreManager {

    // this is used when parent / child contexts saving managed object. Child context saves managed object, parent will merge that child context changes to main context.
    // then this notification would get triggered.
    // here context, it should be context for which this managed object is registered. Using object id, load managed object into target context.
    @nonobjc
    func didMergeNotificationPublisher<T: NSManagedObject, C: NSManagedObjectContext>(for managedObject: T, in context: C) -> AnyPublisher<T, Never> {
        let notificationName = NSManagedObjectContext.didSaveObjectIDsNotification // I have updated notification from merge to didSave
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

}

// MARK: NSFetchedResultsController
extension StoreManager {
    
}

// MARK: Synchronize context changes with persistent store.
extension StoreManager {

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
