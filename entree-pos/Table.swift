
class Table: PFObject, PFSubclassing {
    
    @NSManaged var capacity: Int
    @NSManaged var currentParty: Party?
    @NSManaged var name: String
    @NSManaged var restaurant: Restaurant
    @NSManaged var shortName: String
    @NSManaged var type: Int
    @NSManaged var x: CGFloat
    @NSManaged var y: CGFloat
    
    static func parseClassName() -> String {
        return "Table"
    }
    
}