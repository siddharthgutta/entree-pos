
class Restaurant: PFObject, PFSubclassing {
    
    @NSManaged var cardFlightAccountToken: String
    @NSManaged var location: String
    @NSManaged var name: String
    @NSManaged var user: PFUser
    
    static func sharedRestaurant() -> Restaurant {
        return Restaurant(withoutDataWithObjectId: NSUserDefaults.standardUserDefaults().objectForKey("shared_restaurant_object_id") as? String)
    }
    
    static func parseClassName() -> String {
        return "Restaurant"
    }
    
}
