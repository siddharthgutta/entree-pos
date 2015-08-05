
class OrderItem: PFObject, PFSubclassing {
    
    @NSManaged var menuItem: MenuItem
    @NSManaged var menuItemModifiers: [MenuItemModifier]
    @NSManaged var notes: String
    @NSManaged var onTheHouse: Bool
    @NSManaged var order: Order
    @NSManaged var party: Party
    @NSManaged var seatNumber: Int
    @NSManaged var timesPrinted: Int
    
    static func parseClassName() -> String {
        return "OrderItem"
    }
    
    func tax() -> Double {
        var orderTax: Double = 0
        
        if menuItem.alcoholic {
            let alcoholTaxRate = NSUserDefaults.standardUserDefaults().objectForKey("alcohol_tax_rate")! as! Double
            orderTax += (totalCost() * alcoholTaxRate)
        }
        
        let salesTaxRate = NSUserDefaults.standardUserDefaults().objectForKey("sales_tax_rate")! as! Double
        orderTax += (totalCost() * salesTaxRate)
        
        return orderTax
    }
    
    func totalCost() -> Double {
        return onTheHouse ? 0 : menuItemModifiers.reduce(menuItem.price) { (price: Double, modifier: MenuItemModifier) -> Double in return price + modifier.price }
    }
    
}