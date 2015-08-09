
class Restaurant: PFObject, PFSubclassing {
    
    @NSManaged var alcoholTaxRate: Double
    @NSManaged var cardFlightAccountToken: String
    @NSManaged var location: String
    @NSManaged var name: String
    @NSManaged var salesTaxRate: Double
    
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
    
    static func asynchronouslyFetchDefaultRestaurantWithCompletion(completion: (Bool, Restaurant?) -> Void) {
        if let objectID = defaultRestaurantObjectID() {
            let query = Restaurant.query()!
            
            query.getObjectInBackgroundWithId(objectID) { (object: PFObject?, error: NSError?) in
                if let restaurant = object as? Restaurant {
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
            
            return query.getObjectWithId(objectID) as? Restaurant
        } else {
            return nil
        }
    }
    
    static func parseClassName() -> String {
        return "Restaurant"
    }
    
}
