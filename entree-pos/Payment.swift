
class Payment: PFObject, PFSubclassing {
    
    @NSManaged var type: String
    
    @NSManaged var authorized: Bool
    @NSManaged var cardFlightChargeToken: String?
    @NSManaged var cardLastFour: String?
    @NSManaged var cardName: String?
    @NSManaged var paid: Bool
    
    @NSManaged var orders: [Order]
    
    @NSManaged var subtotal: Double
    @NSManaged var tax: Double
    @NSManaged var total: Double
    
    @NSManaged var tip: Double
    
    init(type: String, orders: [Order]) {
        super.init()
        
        self.type = type
        
        self.authorized = false
        self.cardFlightChargeToken = nil
        self.cardLastFour = nil
        self.cardName = nil
        self.paid = false
        
        self.orders = orders
        
        calculateTotal()
        
        self.tip = 0
    }
    
    func calculateTotal() {
        subtotal = orders.reduce(0) { (s: Double, order: Order) -> Double in return s + order.price() }
        tax = orders.reduce(0) { (t: Double, order: Order) -> Double in return t + order.tax() }
        total = orders.reduce(0) { (t: Double, order: Order) -> Double in return t + order.total() }
    }
    
    static func parseClassName() -> String {
        return "Payment"
    }
    
}