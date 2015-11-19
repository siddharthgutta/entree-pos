
public class MenuCategory: PFObject, PFSubclassing {
    
    @NSManaged var colorIndex: Int
    @NSManaged var menu: Menu
    @NSManaged var name: String
    
    public static func parseClassName() -> String {
        return "MenuCategory"
    }
    
}
