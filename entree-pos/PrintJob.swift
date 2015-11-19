
public class PrintJob: PFObject, PFSubclassing {
    
    @NSManaged var text: String
    @NSManaged var printer: StarPrinter
    
    public static func parseClassName() -> String {
        return "PrintJob"
    }
    
}