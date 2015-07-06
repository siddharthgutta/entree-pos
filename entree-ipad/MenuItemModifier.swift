
class MenuItemModifier: PFObject, PFSubclassing {
    
    @NSManaged var menuItems: PFRelation
    @NSManaged var name: String
    @NSManaged var price: Double
    @NSManaged var printJobs: [PrintJob]
    
    static func parseClassName() -> String {
        return "MenuItemModifier"
    }
    
}
