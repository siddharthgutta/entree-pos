
class MenuItem: PFObject, PFSubclassing {
    
    @NSManaged var itemDescription: String
    @NSManaged var menuCategory: MenuCategory
    @NSManaged var name: String
    @NSManaged var price: Double
    
    static func parseClassName() -> String {
        return "MenuItem"
    }
    
}
