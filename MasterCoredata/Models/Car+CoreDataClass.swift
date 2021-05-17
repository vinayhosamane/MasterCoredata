//
//  Car+CoreDataClass.swift
//  MasterCoredata
//
//  Created by Hosamane, Vinay K N on 06/05/21.
//
//

import Foundation
import CoreData

@objc(Car)
public class Car: NSManagedObject {
    
    // A convenience method to add owner of the car
    func addOwner(_ owner: Person? = nil) {
        guard let owner = owner else {
            return
        }
        self.owner = owner
    }

}
