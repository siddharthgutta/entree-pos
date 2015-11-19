
public class MenuItem: PFObject, PFSubclassing {
    
    @NSManaged var alcoholic: Bool
    @NSManaged var colorIndex: Int
    @NSManaged var menuCategory: MenuCategory
    @NSManaged var name: String
    @NSManaged var price: Double
    @NSManaged var printJobs: [PrintJob]
    
    public static func parseClassName() -> String {
        return "MenuItem"
    }
    
}
