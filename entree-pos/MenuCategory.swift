
class MenuCategory: PFObject, PFSubclassing {
    
    @NSManaged var colorIndex: Int
    @NSManaged var menu: Menu
    @NSManaged var name: String
    
    static func parseClassName() -> String {
        return "MenuCategory"
    }
    
}
