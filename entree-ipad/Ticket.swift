
class Ticket: PFObject, PFSubclassing {
    
    @NSManaged var cardFlightChargeToken: String
    @NSManaged var paid: Bool
    @NSManaged var party: Party
    @NSManaged var paymentType: String
    @NSManaged var restaurant: Restaurant
    @NSManaged var tax: Double
    @NSManaged var total: Double
    
    static func parseClassName() -> String {
        return "Ticket"
    }
    
}
