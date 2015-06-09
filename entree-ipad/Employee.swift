
class Employee: PFObject, PFSubclassing {
    
    @NSManaged var activePartyCount: Int
    @NSManaged var avatarFile: PFFile?
    @NSManaged var administrator: Bool
    @NSManaged var currentShift: Shift?
    @NSManaged var hourlyWage: Double
    @NSManaged var name: String
    @NSManaged var pinCode: String
    @NSManaged var restaurant: Restaurant
    @NSManaged var role: String
    
    static func parseClassName() -> String {
        return "Employee"
    }
    
}
