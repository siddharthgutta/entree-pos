
class MenuItemModifier: PFObject, PFSubclassing {
    
    @NSManaged var menuItems: PFRelation
    @NSManaged var name: String
    @NSManaged var price: Double
    
    static func parseClassName() -> String {
        return "MenuItemModifier"
    }
    
}
