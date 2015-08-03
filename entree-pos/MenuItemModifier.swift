
class MenuItemModifier: PFObject, PFSubclassing {
    
    @NSManaged var menuItems: PFRelation
    @NSManaged var name: String
    @NSManaged var price: Double
    @NSManaged var printText: String
    
    static func parseClassName() -> String {
        return "MenuItemModifier"
    }
    
}
