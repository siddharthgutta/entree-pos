
class Order: PFObject, PFSubclassing {
    
    @NSManaged var orderItems: [OrderItem]
    @NSManaged var payment: Payment
    
    func subtotal() -> Double {
        return orderItems.reduce(0) { (subtotal: Double, orderItem: OrderItem) -> Double in return subtotal + orderItem.totalCost() }
    }
    
    func tax() -> Double {
        return orderItems.reduce(0) { (subtotal: Double, orderItem: OrderItem) -> Double in return subtotal + orderItem.tax() }
    }
    
    func total() -> Double {
        return subtotal() + tax()
    }
    
    static func parseClassName() -> String {
        return "Order"
    }
    
}
