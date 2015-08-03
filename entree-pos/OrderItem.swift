
class OrderItem: PFObject, PFSubclassing {
    
    @NSManaged var menuItem: MenuItem
    @NSManaged var menuItemModifiers: [MenuItemModifier]
    @NSManaged var notes: String
    @NSManaged var numberOfTimesPrinted: Int
    @NSManaged var party: Party
    @NSManaged var payment: Payment
    @NSManaged var seatNumber: Int
    
    static func parseClassName() -> String {
        return "OrderItem"
    }
    
    func totalCost() -> Double {
        return menuItemModifiers.reduce(menuItem.price) { (price: Double, modifier: MenuItemModifier) -> Double in return price + modifier.price }
    }
    
}