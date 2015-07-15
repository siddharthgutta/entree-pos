
import UIKit

let _PrintManagerSharedInstance = PrintManager()

class PrintManager: NSObject, PrinterDelegate {
   
    private var macAddressToPrinterMap = [String: Printer]()
    
    var start = NSDate()
    
    // MARK: - Static methods
    
    static func sharedManager() -> PrintManager {
        return _PrintManagerSharedInstance
    }
    
    // MARK: - Instance methods
    
    private func executePrintJobsForOrder(order: Order) {
        let orderTemplateFilePath = NSBundle.mainBundle().pathForResource("order_template", ofType: "xml")
        
        for printJob in order.menuItem.printJobs {
            let dictionary = [
                "menu_item": printJob.text.isEmpty ? order.menuItem.name : printJob.text,
                "seat": order.seat == 0 ? "SEAT: NOT SET" : "SEAT: \(order.seat)",
                "mods": order.menuItemModifiers.isEmpty ? "NO MODIFIERS" : ", ".join(order.menuItemModifiers.map { (modifier: MenuItemModifier) -> String in return modifier.printText }),
                "notes": order.notes.isEmpty ? "NO NOTES" : order.notes]
            let printData = PrintData(dictionary: dictionary, atFilePath: orderTemplateFilePath)
            
            printPrintData(printData, toStarPrinter: printJob.printer)
        }
    }
    
    private func printPrintData(printData: PrintData, toStarPrinter starPrinter: StarPrinter) {
        if let printer = macAddressToPrinterMap[starPrinter.mac] {
            if printer.status.value == PrinterStatusConnected.value {
                printer.print(printData)
                println("PRINT COMPLETE AFTER \(-1 * self.start.timeIntervalSinceNow)")
            } else {
                printer.connect { (success: Bool) -> Void in
                    if success {
                        printer.print(printData)
                        println("PRINT COMPLETE AFTER \(-1 * self.start.timeIntervalSinceNow)")
                    } else {
                        println("COULD NOT CONNECT TO PRINTER: \(printer.macAddress)")
                    }
                }
            }
        } else {
            println("PRINTER NOT FOUND. REFRESHING AVAILABLE PRINTERS...")
            
            refreshAvailablePrintersWithCompletion { () in self.printPrintData(printData, toStarPrinter: starPrinter) }
        }
    }
    
    func printOrders(orders: [Order]) {
        start = NSDate()
        for order in orders { self.executePrintJobsForOrder(order) }
    }
    
    private func refreshAvailablePrintersWithCompletion(completion: Void -> Void) {
        Printer.search { (results: [AnyObject]!) in
            let printers = results as! [Printer]
            
            for printer in printers {
                printer.delegate = self
                self.macAddressToPrinterMap[printer.macAddress] = printer
            }
            
            completion()
        }
    }
    
    // MARK: - PrinterDelegate
    
    func printer(printer: Printer!, didChangeStatus status: PrinterStatus) {
       //  println("PRINTER: \(printer.macAddress) DID CHANGE STATUS: \(status.value)")
    }
    
}
