
class Table: PFObject, PFSubclassing {
    
    @NSManaged var capacity: Int
    @NSManaged var name: String
    @NSManaged var occupied: Bool
    @NSManaged var restaurant: Restaurant
    @NSManaged var shortName: String
    @NSManaged var type: Int
    @NSManaged var x: Double
    @NSManaged var y: Double
    
    static func parseClassName() -> String {
        return "Table"
    }
    
}