
class StarPrinter: PFObject, PFSubclassing {
    
    @NSManaged var mac: String
    @NSManaged var nickname: String
    @NSManaged var restaurant: Restaurant
 
    static func parseClassName() -> String {
        return "StarPrinter"
    }
    
}