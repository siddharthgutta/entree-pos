
class Payment: PFObject, PFSubclassing {
    
    @NSManaged var cardFlightChargeToken: String
    @NSManaged var cardLastFour: String
    @NSManaged var cardName: String
    @NSManaged var subtotal: Double
    @NSManaged var tax: Double
    @NSManaged var tip: Double
    @NSManaged var total: Double // (subtotal + tax + tip)
    @NSManaged var type: String // Either Card or Cash
    
    static func parseClassName() -> String {
        return "Payment"
    }
    
}