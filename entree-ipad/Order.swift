
class Order: PFObject, PFSubclassing {
    
    @NSManaged var menuItem: MenuItem
    @NSManaged var menuItemModifiers: [MenuItemModifier]
    @NSManaged var notes: String
    @NSManaged var party: Party
    @NSManaged var seat: Int
    
    func totalPrice() -> Double {
        return menuItemModifiers.reduce(menuItem.price) { (price: Double, modifier: MenuItemModifier) -> Double in
            return price + modifier.price
        }
    }
    
    static func parseClassName() -> String {
        return "Order"
    }
    
}
