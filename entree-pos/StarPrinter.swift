
public class StarPrinter: PFObject, PFSubclassing {
    
    @NSManaged var mac: String
    @NSManaged var nickname: String
    @NSManaged var restaurant: Restaurant
 
    public static func parseClassName() -> String {
        return "StarPrinter"
    }
    
}