
public class MenuItemModifier: PFObject, PFSubclassing {
    
    @NSManaged var menuItems: PFRelation
    @NSManaged var name: String
    @NSManaged var price: Double
    @NSManaged var printText: String
    
    public static func parseClassName() -> String {
        return "MenuItemModifier"
    }
    
}
