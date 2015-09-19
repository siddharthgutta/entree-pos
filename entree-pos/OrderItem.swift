
class OrderItem: PFObject, PFSubclassing {
    
    @NSManaged var order: Order?
    @NSManaged var party: Party?
    
    @NSManaged var menuItem: MenuItem
    @NSManaged var menuItemModifiers: [MenuItemModifier]
    
    @NSManaged var seatNumber: Int
    @NSManaged var notes: String
    @NSManaged var onTheHouse: Bool
    
    @NSManaged var sentToKitchen: Bool
    @NSManaged var printedToCheck: Bool
    
    // Cost of item without tax
    
    func itemCost() -> Double {
        return onTheHouse ? 0 : menuItemModifiers.reduce(menuItem.price) { (price: Double, modifier: MenuItemModifier) -> Double in
            return price + modifier.price
        }
    }
    
    // Applicable tax for item
    
    func applicableTax() -> Double {
        var tax = 0.0

        let restaurant = Restaurant.defaultRestaurantFromLocalDatastoreFetchIfNil()!
        
        if menuItem.alcoholic {
            tax += (itemCost() * restaurant.alcoholTaxRate)
        }
        
        tax += (itemCost() * restaurant.salesTaxRate)
        
        return tax
    }
    
    // Total cost of item (Tax included)
    
    func totalCost() -> Double {
        return itemCost() + applicableTax()
    }
    
    static func parseClassName() -> String {
        return "OrderItem"
    }
    
}