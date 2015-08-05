
import UIKit

let _ReceiptPrinterManagerSharedInstance = ReceiptPrinterManager()

class ReceiptPrinterManager {
   
    private var macAddressToPrinterCache = [String: Printer]()
    var receiptPrinterMACAddress: String? {
        return NSUserDefaults.standardUserDefaults().objectForKey("receipt_printer_mac_address") as? String
    }
    
    // MARK: - Static methods
    
    static func sharedManager() -> ReceiptPrinterManager {
        return _ReceiptPrinterManagerSharedInstance
    }
    
    // MARK: - ReceiptPrinterManager
    
    private func connectToPrinter(printer: Printer, andPrintData printData: PrintData, completion: (Bool) -> (Void)) {
        if printer.isConnected {
            completion(true)
        } else {
            printer.connect { (success: Bool) in
                completion(success)
            }
        }
    }
    
    private func findPrinterWithMacAddress(address: String, attempt: Int, completion: (Bool, Printer?) -> Void) {
        if attempt > 3 {
            completion(false, nil)
        } else {
            if let cachedPrinter = macAddressToPrinterCache[address] {
                completion(true, cachedPrinter)
            } else {
                refreshAvailablePrintersWithCompletion { () in
                    self.findPrinterWithMacAddress(address, attempt: attempt + 1, completion: completion)
                }
            }
        }
    }
    
    func findPrinterWithMACAddress(address: String, completion: Printer? -> Void) {
        if let cachedPrinter = macAddressToPrinterCache[address] {
            completion(cachedPrinter)
        } else {
            refreshAvailablePrintersWithCompletion { () in
                self.findPrinterWithMACAddress(address, completion: completion)
            }
        }
    }
    
    func openCashDrawer() {
        if let address = receiptPrinterMACAddress {
            let filePath = NSBundle.mainBundle().pathForResource("open_cash_drawer", ofType: "xml")
            let printData = PrintData(dictionary: nil, atFilePath: filePath)
            
            sendPrintData(printData, toPrinterWithMACAddress: address) { (sent: Bool, error: NSError?) in
                println("Sent: \(sent), Error: \(error)")
            }
        }
    }
    
    func search(completion: [Printer] -> Void) {
        Printer.search { (printers: [AnyObject]!) in
            completion(printers as! [Printer])
        }
    }
    
    private func sendPrintData(printData: PrintData, toPrinterWithMACAddress address: String, completion: (Bool, NSError?) -> Void) {
        findPrinterWithMacAddress(address, attempt: 1) { (success: Bool, printer: Printer?) in
            if success {
                self.connectToPrinter(printer!, andPrintData: printData) { (connected: Bool) in
                    if connected {
                        printer!.print(printData)
                        
                        completion(true, nil)
                    } else {
                        completion(false, NSError(domain: "Failed to connect to printer", code: 500, userInfo: nil))
                    }
                }
            } else {
                completion(false, NSError(domain: "Could not find printer", code: 404, userInfo: nil))
            }
        }
    }
    
    // MARK: - Receipt printing
    
    func setReceiptPrinterMacAddress(address: String) {
        NSUserDefaults.standardUserDefaults().setObject(address, forKey: "receipt_printer_mac_address")
    }
    
    func printReceiptForOrder(order: Order, completion: (Bool, NSError?) -> Void) {
        if let address = receiptPrinterMACAddress {
            let dictionary = [
                "restaurant": ""
            ]
            
            let filePath = NSBundle.mainBundle().pathForResource("receipt_template", ofType: "xml")
            
            let printData = PrintData(dictionary: dictionary, atFilePath: filePath)
            
            sendPrintData(printData, toPrinterWithMACAddress: address) { (sent: Bool, error: NSError?) in
                
            }
        } else {
            let error = NSError(domain: "Receipt printer has not been set", code: 0, userInfo: nil)
            completion(false, error)
        }
    }
    
    // MARK: - Kitchen printing
    
    private func executePrintJobsForOrderItem(orderItem: OrderItem) {
        let orderTemplateFilePath = NSBundle.mainBundle().pathForResource("order_template", ofType: "xml")
        
        for printJob in orderItem.menuItem.printJobs {
            let dictionary = [
                "menu_item": printJob.text.isEmpty ? orderItem.menuItem.name : printJob.text,
                "seat": orderItem.seatNumber == 0 ? "SEAT: NOT SET" : "SEAT: \(orderItem.seatNumber)",
                "mods": orderItem.menuItemModifiers.isEmpty ? "NO MODIFIERS" : ", ".join(orderItem.menuItemModifiers.map { (modifier: MenuItemModifier) -> String in return modifier.printText }),
                "notes": orderItem.notes.isEmpty ? "NO NOTES" : orderItem.notes]
            let printData = PrintData(dictionary: dictionary, atFilePath: orderTemplateFilePath)
            
            sendPrintData(printData, toPrinterWithMACAddress: printJob.printer.mac) { (sent: Bool, error: NSError?) in
                // TODO: Maybe move this somehwer else
            }
        }
    }
    
    func printOrderItems(orderItems: [OrderItem]) {
        for orderItem in orderItems {
            self.executePrintJobsForOrderItem(orderItem)
        }
    }
    
    private func refreshAvailablePrintersWithCompletion(completion: Void -> Void) {
        Printer.search { (results: [AnyObject]!) in
            let printers = results as! [Printer]
            
            for printer in printers {
                self.macAddressToPrinterCache[printer.macAddress] = printer
            }
            
            completion()
        }
    }
    
}
