

enum RestaurantError: ErrorType {
    case NoDefaultRestaurant
    case RestaurantNotFound
}

class Restaurant: PFObject, PFSubclassing {
    
    @NSManaged var alcoholTaxRate: Double
    @NSManaged var cardFlightAccountToken: String
    @NSManaged var location: String
    @NSManaged var name: String
    @NSManaged var phone: String
    @NSManaged var salesTaxRate: Double
    
    static func defaultRestaurantFromLocalDatastoreFetchIfNil() -> Restaurant? {
        guard let objectID = Restaurant.defaultRestaurantObjectID() else {
            return nil
        }
        
        do {
            let restaurant = try restaurantQueryFromLocalDatastore(false).getObjectWithId(objectID) as! Restaurant
            return restaurant
        } catch {
            let restaurant = Restaurant.synchronouslyFetchDefaultRestaurant()
            return restaurant
        }
    }
    
    static func defaultRestaurantObjectID() -> String? {
        return NSUserDefaults.standardUserDefaults().objectForKey("default_restaurant") as? String
    }
    
    static func defaultRestaurantWithoutData() -> Restaurant? {
        if let objectID = defaultRestaurantObjectID() {
            return Restaurant(withoutDataWithObjectId: objectID)
        } else {
            return nil
        }
    }
    
    static func restaurantQueryFromLocalDatastore(fromLocalDatastore: Bool) -> PFQuery {
        let query = Restaurant.query()!
        
        if fromLocalDatastore {
            query.fromLocalDatastore()
        }
        
        return query
    }
    
    static func asynchronouslyFetchDefaultRestaurantWithCompletion(completion: (Bool, Restaurant?) -> Void) {
        if let objectID = defaultRestaurantObjectID() {
            let query = Restaurant.query()!
            
            query.getObjectInBackgroundWithId(objectID) { (object: PFObject?, error: NSError?) in
                if let restaurant = object as? Restaurant {
                    try! restaurant.pin()
                    completion(true, restaurant)
                } else {
                    completion(false, nil)
                }
            }
        } else {
            completion(false, nil)
        }
    }
    
    static func setDefaultRestaurantObjectID(id: String) {
        NSUserDefaults.standardUserDefaults().setObject(id, forKey: "default_restaurant")
    }
    
    static func synchronouslyFetchDefaultRestaurant() -> Restaurant? {
        if let objectID = defaultRestaurantObjectID() {
            let query = Restaurant.query()!
            
            if let restaurant = try! query.getObjectWithId(objectID) as? Restaurant {
                try! restaurant.pin()
                
                return restaurant
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    static func parseClassName() -> String {
        return "Restaurant"
    }
    
}
