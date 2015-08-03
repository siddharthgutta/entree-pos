
class Shift: PFObject, PFSubclassing {
    
    @NSManaged var employee: Employee
    @NSManaged var endedAt: NSDate
    @NSManaged var startedAt: NSDate
    
    static func parseClassName() -> String {
        return "Shift"
    }
    
}