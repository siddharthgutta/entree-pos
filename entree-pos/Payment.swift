
class Payment: PFObject, PFSubclassing {
    
    @NSManaged var type: String
    
    @NSManaged var cardFlightChargeToken: String?
    @NSManaged var cardLastFour: String?
    @NSManaged var cardName: String?
    
    @NSManaged var order: Order
    
    @NSManaged var tip: Double
    
    static func parseClassName() -> String {
        return "Payment"
    }
    
}