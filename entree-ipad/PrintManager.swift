
import UIKit

let _PrintManagerSharedInstance = PrintManager()

class PrintManager: NSObject, PrinterDelegate {
   
    private var availablePrinters = [Printer]()
    
    // MARK: - Static methods
    
    static func sharedManager() -> PrintManager {
        return _PrintManagerSharedInstance
    }
    
    // MARK: - Instance methods
    
    private func executePrintJobsForOrder(order: Order) {
        let filePath = NSBundle.mainBundle().pathForResource("order_template", ofType: "xml")
        
        for printJob in order.menuItem.printJobs {
            let dictionary = [
                "menu_item": printJob.text,
                "mods": order.menuItemModifiers.reduce("\(order.menuItemModifiers.first?.printText)") { (prev: String, modifier: MenuItemModifier) -> String in return "\(prev), \(modifier.printText)" },
                "notes": order.notes]
            let printData = PrintData(dictionary: dictionary, atFilePath: filePath)
            
            if let printer = printerForStarPrinter(printJob.printer) {
                printer.print(printData)
            }
        }
    }
    
    private func printerForStarPrinter(starPrinter: StarPrinter) -> Printer? {
        return availablePrinters.filter { (printer: Printer) -> Bool in return printer.macAddress == starPrinter.mac }.first
    }
    
    func printOrders(orders: [Order]) {
        refreshAvailablePrintersWithCompletion() {
            for order in orders { self.executePrintJobsForOrder(order) }
        }
    }
    
    private func refreshAvailablePrintersWithCompletion(completion: Void -> Void) {
        Printer.search { (results: [AnyObject]!) in
            let printers = results as! [Printer]
            
            for printer in printers { printer.delegate = self }
            
            self.availablePrinters = printers
            
            completion()
        }
    }
    
    // MARK: - PrinterDelegate
    
    func printer(printer: Printer!, didChangeStatus status: PrinterStatus) {
        println("Printer: \(printer.name) did change status: \(status)")
    }
    
}
