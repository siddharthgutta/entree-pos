
class Menu: PFObject, PFSubclassing {
    
    @NSManaged var name: String
    @NSManaged var restaurants: PFRelation
    
    static func parseClassName() -> String {
        return "Menu"
    }
    
}
