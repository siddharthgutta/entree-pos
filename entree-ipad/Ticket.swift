
class Ticket: PFObject, PFSubclassing {
    
    @NSManaged var party: Party
    @NSManaged var payment: Payment?

    static func parseClassName() -> String {
        return "Ticket"
    }
    
}
