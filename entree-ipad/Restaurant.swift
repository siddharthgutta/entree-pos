
class Restaurant: PFObject, PFSubclassing {
    
    @NSManaged var cardFlightAccountToken: String
    @NSManaged var location: String
    @NSManaged var name: String
    @NSManaged var user: PFUser
    
    static func parseClassName() -> String {
        return "Restaurant"
    }
    
}
