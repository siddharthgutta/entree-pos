
class Order: PFObject, PFSubclassing {

    @NSManaged var restaurant: Restaurant
    @NSManaged var type: String // "Full Service", "Quick Service", "Customer Tab", or "To Go"
    @NSManaged var installation: PFInstallation
    @NSManaged var name: String?

    @NSManaged var orderItems: [OrderItem]
    
    @NSManaged var amountDue: Double
    @NSManaged var tax: Double
    @NSManaged var subtotal: Double
    @NSManaged var tip: Double
    @NSManaged var total: Double
    
    @NSManaged var server: Employee
    @NSManaged var party: Party? // Has value for "Full Service" type
    @NSManaged var payment: Payment?
    
    func crunchTheNumbers() {
        amountDue = orderItems.reduce(0) { (amountDue: Double, item: OrderItem) -> Double in
            return amountDue + item.itemCost()
        }
        tax = orderItems.reduce(0) { (tax: Double, item: OrderItem) -> Double in
            return tax + item.applicableTax()
        }
        subtotal = amountDue + tax
        total = subtotal + tip
    }
    
    static func createOrderWithType(type: String, name: String?, party: Party, orderItems items: [OrderItem]) -> Order {
        let order = Order()
        
        order.restaurant = Restaurant.defaultRestaurantFromLocalDatastoreFetchIfNil()!
        order.type = type
        order.installation = PFInstallation.currentInstallation()
        order.name = name
        order.party = party
        order.server = party.server
        
        order.orderItems = items
        
        for item in items {
            item.order = order
        }
        
        order.amountDue = items.reduce(0) { (amountDue: Double, item: OrderItem) -> Double in
            return amountDue + item.itemCost()
        }
        order.tax = items.reduce(0) { (tax: Double, item: OrderItem) -> Double in
            return tax + item.applicableTax()
        }
        order.subtotal = order.amountDue + order.tax
        
        if type == "Cash" {
            order.total = order.subtotal
        }
        
        return order
    }
    
    static func parseClassName() -> String {
        return "Order"
    }
    
}
