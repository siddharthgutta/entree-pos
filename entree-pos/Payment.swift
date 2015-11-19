
public class Payment: PFObject, PFSubclassing {
    
    @NSManaged var restaurant: Restaurant
    @NSManaged var type: String // Either "Card" or "Cash"
    @NSManaged var order: Order
    
    // "Card" Type
    @NSManaged var cardFlightChargeToken: String?
    @NSManaged var cardLastFour: String?
    @NSManaged var cardName: String?
    @NSManaged var cardType: String?
    @NSManaged var charged: Bool
    
    // "Cash" Type
    @NSManaged var cashAmountPaid: Double
    @NSManaged var changeGiven: Double

    public static func parseClassName() -> String {
        return "Payment"
    }
    
}