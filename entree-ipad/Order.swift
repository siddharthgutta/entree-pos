
class Order: PFObject, PFSubclassing {
    
    @NSManaged var menuItem: MenuItem
    @NSManaged var menuItemModifiers: MenuItemModifier
    @NSManaged var notes: String
    @NSManaged var restaurant: Restaurant
    @NSManaged var seat: Int
    
    static func parseClassName() -> String {
        return "Order"
    }
    
}
