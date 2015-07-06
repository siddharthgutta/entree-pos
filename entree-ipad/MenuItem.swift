
class MenuItem: PFObject, PFSubclassing {
    
    @NSManaged var colorIndex: Int
    @NSManaged var itemDescription: String
    @NSManaged var menuCategory: MenuCategory
    @NSManaged var name: String
    @NSManaged var price: Double
    @NSManaged var printJobs: [PrintJob]
    
    static func parseClassName() -> String {
        return "MenuItem"
    }
    
}
