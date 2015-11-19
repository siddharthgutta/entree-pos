
public class Menu: PFObject, PFSubclassing {
    
    @NSManaged var colorIndex: Int
    @NSManaged var name: String
    @NSManaged var restaurants: PFRelation
    
    public static func parseClassName() -> String {
        return "Menu"
    }
    
}
