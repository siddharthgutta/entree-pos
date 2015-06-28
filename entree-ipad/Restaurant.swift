
class Restaurant: PFObject, PFSubclassing {
    
    @NSManaged var cardFlightAccountToken: String
    @NSManaged var location: String
    @NSManaged var name: String
    @NSManaged var user: PFUser
    
    static func defaultRestaurant() -> Restaurant? {
        return Restaurant(withoutDataWithObjectId: NSUserDefaults.standardUserDefaults().objectForKey("default_restaurant") as? String)
    }
    
    static func parseClassName() -> String {
        return "Restaurant"
    }
    
}
