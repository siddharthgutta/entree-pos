
import UIKit
import StarKit

enum PrintingManagerError: ErrorType {
    case NoReceiptPrinter
    case PrinterNotFound
}

public class PrintingManager {
    
    public static var receiptPrinterMACAddress: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("receipt_printer_mac_address") as? String
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: "receipt_printer_mac_address")
        }
    }
    
    private static var printerCache = [String: Printer]()
    
    private static var dateFormatter: NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }
    
    private static var currencyNumberFormatter: NSNumberFormatter {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        return formatter
    }
    
    // MARK: - PrintingManager
    
    private static func getPrinterWithMACAddress(address: String, handler: (Printer?) -> ()) {
        if let cachedPrinter = PrintingManager.printerCache[address] {
            handler(cachedPrinter)
            return
        }
        
        Printer.searchForLANPrintersWithCompletionHandler { printers in
            for printer in printers {
                PrintingManager.printerCache[printer.macAddress] = printer
            }
            
            if let printer = PrintingManager.printerCache[address] {
                handler(printer)
            } else {
                handler(nil)
            }
        }
    }
    
    private static func sendPrintData(printData: PrintData, toPrinterWithMACAddress address: String) {
        getPrinterWithMACAddress(address) { printer in
            printer?.printData(printData, completionHandler: {})
        }
    }
    
    // MARK: - Receipt printing
    
    public static func printReceiptForOrder(order: Order) throws {
        guard let address = PrintingManager.receiptPrinterMACAddress else {
            throw PrintingManagerError.NoReceiptPrinter
        }
        
        let isCardPayment = order.payment?.type == "Card"
        
        // Synchronously fetch restaurant for header information
        let defaultRestuarant = Restaurant.defaultRestaurantFromLocalDatastoreFetchIfNil()!
        
        var orderItemsXML = ""
        for orderItem in order.orderItems {
            let itemCost = currencyNumberFormatter.stringFromDouble(orderItem.itemCost())!
            orderItemsXML += "[\(itemCost)] \(orderItem.menuItem.name)<newline />"
        }
        
        var dictionary = [
            "{{copy}}": "Customer Copy",
            "{{restaurant}}": defaultRestuarant.name,
            "{{location}}": defaultRestuarant.location,
            "{{phone}}": defaultRestuarant.phone,
            "{{time}}": dateFormatter.stringFromDate(NSDate()),
            "{{server}}": order.server.name,
            "{{order_id}}": order.objectId!,
            "{{payment_id}}": order.payment!.objectId!,
            "{{order_items}}": orderItemsXML,
            "{{subtotal}}": currencyNumberFormatter.stringFromDouble(order.subtotal)!
        ]
        
        if isCardPayment {
            dictionary["{{last_four}}"] = order.payment!.cardLastFour!
            dictionary["{{cardholder}}"] = order.payment!.cardName!
        } else {
            dictionary["{{cash_amount_paid}}"] = currencyNumberFormatter.stringFromDouble(order.payment!.cashAmountPaid)
            dictionary["{{change_given}}"] = currencyNumberFormatter.stringFromDouble(order.payment!.changeGiven)
        }
        
        let filePath = NSBundle.mainBundle().pathForResource("\(order.payment!.type.lowercaseString)_receipt_template", ofType: "xml")!
        
        let printData = PrintData(dictionary: dictionary, filePath: filePath)
        
        PrintingManager.sendPrintData(printData, toPrinterWithMACAddress: address)
        
        if isCardPayment {
            dictionary["{{copy}}"] = "Merchant Copy"
            let printData = PrintData(dictionary: dictionary, filePath: filePath)
            PrintingManager.sendPrintData(printData, toPrinterWithMACAddress: address)
        }

    }
    
    // MARK: - Check printing
    
    public static func printCheckForOrderItems(orderItems: [OrderItem], party: Party) throws {
        guard let address = PrintingManager.receiptPrinterMACAddress else {
            throw PrintingManagerError.NoReceiptPrinter
        }
        
        let checkTemplateFilePath = NSBundle.mainBundle().pathForResource("check_template", ofType: "xml")!
        
        // Synchronously fetch restaurant for header information
        let defaultRestuarant = Restaurant.defaultRestaurantFromLocalDatastoreFetchIfNil()!
        
        // Stitch together template language for each order item
        var orderItemsXML = ""
        for orderItem in orderItems {
            
            let itemName = orderItem.menuItem.name
            let price = currencyNumberFormatter.stringFromDouble(orderItem.itemCost())!
            
            orderItemsXML += "<left><text>\(itemName)</text></left><newline /><right><text>\(price)</text></right><newline />"
        }
        
        // Calculate totals for the bottom of the check
        let amountDue = orderItems.reduce(0) {
            (amountDue, item) in
            return amountDue + item.itemCost()
        }
        let tax = orderItems.reduce(0) {
            (tax, item) in
            return tax + item.applicableTax()
        }
        let subtotal = amountDue + tax
        
        let dictionary = [
            "{{restaurant}}": defaultRestuarant.name,
            "{{location}}": defaultRestuarant.location,
            "{{phone}}": defaultRestuarant.phone,
            "{{time}}": dateFormatter.stringFromDate(NSDate()),
            "{{server}}": party.server.name,
            "{{items}}": orderItemsXML,
            "{{amount_due}}": currencyNumberFormatter.stringFromNumber(NSNumber(double: amountDue))!,
            "{{tax}}": currencyNumberFormatter.stringFromNumber(NSNumber(double: tax))!,
            "{{subtotal}}": currencyNumberFormatter.stringFromNumber(NSNumber(double: subtotal))!
        ]
        
        let printData = PrintData(dictionary: dictionary, filePath: checkTemplateFilePath)
        
        PrintingManager.sendPrintData(printData, toPrinterWithMACAddress: address)
    }
    
    // MARK: - Kitchen printing
    
    public static func printOrderItems(orderItems: [OrderItem], party: Party?, server: Employee, toGo: Bool) {
        // FIXME: Wildly complex and inefficient way to do this
        
        var printJobs = [PrintJob]()
        var printJobObjectIdToOrderItemMap = [String: OrderItem]()
        var printerMACAddressToPrintJobsMap = [String: [PrintJob]]()
        
        for orderItem in orderItems {
            printJobs += orderItem.menuItem.printJobs
            for printJob in orderItem.menuItem.printJobs {
                printJobObjectIdToOrderItemMap[printJob.objectId!] = orderItem
            }
        }
        
        for printJob in printJobs {
            if printerMACAddressToPrintJobsMap[printJob.printer.mac] != nil {
                printerMACAddressToPrintJobsMap[printJob.printer.mac]!.append(printJob)
            } else {
                printerMACAddressToPrintJobsMap[printJob.printer.mac] = [printJob]
            }
        }
        
        for (printerAddress, _) in printerMACAddressToPrintJobsMap {
            var dictionary = [
                "{{location}}": toGo ? "To Go" : "Dine-In",
                "{{time}}": dateFormatter.stringFromDate(NSDate()),
                "{{table}}": party?.table?.name ?? "",
                "{{server}}": server.name,
            ]
            
            var menuItemsTemplate = ""
            
            let printJobsForPrinter = printerMACAddressToPrintJobsMap[printerAddress]!

            for printJob in printJobsForPrinter {
                let orderItem = printJobObjectIdToOrderItemMap[printJob.objectId!]!
                
                let menuItemXML = "<left /><large>-" + (printJob.text.isEmpty ? orderItem.menuItem.name : printJob.text) + "</large><newline />"
                
                let seatXML = orderItem.seatNumber == 0 ? "" : "<tab /><large>+ SEAT: \(orderItem.seatNumber)</large><newline />"
                
                var modsXML = ""
                if !orderItem.menuItemModifiers.isEmpty {
                    modsXML = orderItem.menuItemModifiers.reduce("") {
                        (previous, modifier) in
                        return "\(previous)<tab /><large><invertcolor>+ \(modifier.name)</invertcolor></large><newline />"
                    }
                }
                
                let notesXML = orderItem.notes.isEmpty ? "" : "<tab /><large><invertcolor>+ \(orderItem.notes)</invertcolor></large><newline />"
                
                let menuItemTemplate = menuItemXML + seatXML + modsXML + notesXML
                menuItemsTemplate += menuItemTemplate
            }
            
            dictionary["{{menu_items}}"] = menuItemsTemplate
            
            let orderItemTemplateFilePath = NSBundle.mainBundle().pathForResource("order_item_template", ofType: "xml")!
            let printData = PrintData(dictionary: dictionary, filePath: orderItemTemplateFilePath)
            
            PrintingManager.sendPrintData(printData, toPrinterWithMACAddress: printerAddress)
        }
    }
    
    public static func printDailySummaryForServer(server: Employee, date: NSDate) throws {
        guard let address = PrintingManager.receiptPrinterMACAddress else {
            throw PrintingManagerError.NoReceiptPrinter
        }
        
        let query = Order.query()
        query?.limit = 1000
        
        query?.includeKey("payment")
        
        query?.whereKey("createdAt", greaterThanOrEqualTo: NSCalendar.currentCalendar().startOfDayForDate(date))
        query?.whereKey("createdAt", lessThan: NSCalendar.currentCalendar().startOfDayForDate(date.dateByAddingTimeInterval(86400)))
        query?.whereKey("server", equalTo: server)
        
        query?.whereKeyExists("payment")
        
        let orders = try query?.findObjects() as! [Order]
        
        let ordersTemplate = orders.reduce("") { previous, order in
            let orderID = order.objectId!
            let paymentType = order.payment!.type
            let subtotal = currencyNumberFormatter.stringFromDouble(order.subtotal)!
            let tip = currencyNumberFormatter.stringFromDouble(order.tip)!
            return "\(previous)Order ID: \(orderID)<newline /><tab>Payment Type: \(paymentType)<newline /><tab>Subtotal: \(subtotal)<newline /><tab>Tip: \(tip)<newline /><newline />"
        }
        
        let cardTotal = orders.reduce(0) { total, order in
            return total + (order.payment!.type == "Card" ? order.subtotal : 0)
        }
        let cashTotal = orders.reduce(0) { total, order in
            return total + (order.payment!.type == "Cash" ? order.subtotal : 0)
        }
        let tips = orders.reduce(0) { total, order in
            return total + order.tip
        }
        
        let dictionary = [
            "{{name}}": server.name,
            "{{date}}": dateFormatter.stringFromDate(date),
            "{{orders}}": ordersTemplate,
            "{{card}}": currencyNumberFormatter.stringFromDouble(cardTotal)!,
            "{{cash}}": currencyNumberFormatter.stringFromDouble(cashTotal)!,
            "{{tips}}": currencyNumberFormatter.stringFromDouble(tips)!
        ]
        
        let filePath = NSBundle.mainBundle().pathForResource("server_summary_template", ofType: "xml")!
        let printData = PrintData(dictionary: dictionary, filePath: filePath)
        
        PrintingManager.sendPrintData(printData, toPrinterWithMACAddress: address)
    }
    
}