
class Party: PFObject, PFSubclassing {
    
    @NSManaged var arrivedAt: NSDate
    @NSManaged var leftAt: NSDate
    @NSManaged var name: String
    @NSManaged var restaurant: Restaurant
    @NSManaged var seatedAt: NSDate
    @NSManaged var server: Employee
    @NSManaged var size: Int
    @NSManaged var table: Table
    
    static func parseClassName() -> String {
        return "Party"
    }
    
}