
class PrintJob: PFObject, PFSubclassing {
    
    @NSManaged var text: String
    @NSManaged var printer: StarPrinter
    
    static func parseClassName() -> String {
        return "PrintJob"
    }
    
}