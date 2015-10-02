
class Party: PFObject, PFSubclassing {
    
    @NSManaged var restaurant: Restaurant
    @NSManaged var arrivedAt: NSDate
    @NSManaged var leftAt: NSDate?
    @NSManaged var seatedAt: NSDate?
    
    @NSManaged var server: Employee
    @NSManaged var table: Table?
    @NSManaged var name: String?
    @NSManaged var size: Int // 0 for null
    @NSManaged var customerTab: Bool
    
    static func partyWithServer(server: Employee, table: Table?, name: String?, size: Int, customerTab: Bool) -> Party {
        let party = Party()
        
        party.restaurant = Restaurant.defaultRestaurantFromLocalDatastoreFetchIfNil()!
        party.arrivedAt = NSDate()
        
        party.server = server
        party.table = table
        party.name = name
        party.size = size
        party.customerTab = customerTab
        
        return party
    }
    
    static func parseClassName() -> String {
        return "Party"
    }
    
}