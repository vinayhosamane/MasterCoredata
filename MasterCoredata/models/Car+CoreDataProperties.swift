//
//  Car+CoreDataProperties.swift
//  MasterCoredata
//
//  Created by Hosamane, Vinay K N on 06/05/21.
//
//

import Foundation
import CoreData

extension Car {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Car> {
        return NSFetchRequest<Car>(entityName: "Car")
    }

    @NSManaged public var maker: String?
    @NSManaged public var model: String?
    @NSManaged public var owner: Person?

}

extension Car : Identifiable {

}
