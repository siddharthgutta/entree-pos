
class Party: PFObject, PFSubclassing {
    
    @NSManaged var restaurant: Restaurant
    
    @NSManaged var arrivedAt: NSDate
    @NSManaged var leftAt: NSDate
    @NSManaged var seatedAt: NSDate
    
    @NSManaged var server: Employee
    @NSManaged var table: Table
    
    @NSManaged var name: String
    @NSManaged var size: Int
    
    func orderItems() -> PFRelation {
        return self.relationForKey("orderItems")
    }
    
    static func parseClassName() -> String {
        return "Party"
    }
    
}