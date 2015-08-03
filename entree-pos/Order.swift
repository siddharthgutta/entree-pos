
class Order: PFObject, PFSubclassing {
    
    @NSManaged var menuItem: MenuItem
    @NSManaged var menuItemModifiers: [MenuItemModifier]
    @NSManaged var notes: String
    @NSManaged var party: Party
    @NSManaged var seat: Int
    
    func price() -> Double {
        return menuItemModifiers.reduce(menuItem.price) { (price: Double, modifier: MenuItemModifier) -> Double in
            return price + modifier.price
        }
    }
    
    func tax() -> Double {
        var orderTax: Double = 0
        
        if menuItem.alcoholic {
            let alcoholTaxRate = NSUserDefaults.standardUserDefaults().objectForKey("alcohol_tax_rate")! as! Double
            orderTax *= (1 + alcoholTaxRate)
        }
        
        let salesTaxRate = NSUserDefaults.standardUserDefaults().objectForKey("sales_tax_rate")! as! Double
        orderTax *= (1 + salesTaxRate)
        
        return orderTax
    }
    
    func total() -> Double {
        return price() + tax()
    }
    
    static func parseClassName() -> String {
        return "Order"
    }
    
}
