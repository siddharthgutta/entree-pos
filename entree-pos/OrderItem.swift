
class OrderItem: PFObject, PFSubclassing {
    
    @NSManaged var menuItem: MenuItem
    @NSManaged var notes: String
    @NSManaged var numberOfTimesPrinted: Int
    @NSManaged var payment: Payment
    
    static func parseClassName() -> String {
        return "OrderItem"
    }
    
}