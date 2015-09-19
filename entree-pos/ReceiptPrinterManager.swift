
import UIKit

class ReceiptPrinterManager {
    
    static let sharedManager = ReceiptPrinterManager()
    
    private var printerCache = [String: Printer]()
    
    private var dateFormatter: NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }
    
    private var currencyNumberFormatter: NSNumberFormatter {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        return formatter
    }
    
    // MARK: - Static printing methods
    
    func openCashDrawer() {
        if let address = ReceiptPrinterManager.receiptPrinterMACAddress() {
            let filePath = NSBundle.mainBundle().pathForResource("open_cash_drawer_template", ofType: "xml")
            
            let printData = PrintData(dictionary: nil, atFilePath: filePath)
            
            ReceiptPrinterManager.sharedManager.sendPrintData(printData, toPrinterWithMACAddress: address)
        } else {
            presentPrinterNotFoundAlertController()
        }
    }
    
    // MARK: - Receipt Printer Management
    
    static func receiptPrinterMACAddress() -> String? {
        return NSUserDefaults.standardUserDefaults().objectForKey("receipt_printer_mac_address") as? String
    }
    
    static func setReceiptPrinterMACAddress(address: String) {
        NSUserDefaults.standardUserDefaults().setObject(address, forKey: "receipt_printer_mac_address")
    }
    
    // MARK: - ReceiptPrinterManager
    
    private func presentPrinterNotFoundAlertController() {
        let printerNotFoundAlertController = UIAlertController(title: "Printer Not Found", message: nil, preferredStyle: .Alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        printerNotFoundAlertController.addAction(okayAction)
        
        UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(printerNotFoundAlertController, animated: true, completion: nil)
    }
    
    func getPrinterWithMACAddress(address: String, handler: (Printer) -> ()) {
        if let cachedPrinter = printerCache[address] {
            handler(cachedPrinter)
        } else {
            Printer.search { (results: [AnyObject]!) in
                let printers = results as! [Printer]
                
                for printer in printers {
                    self.printerCache[printer.macAddress] = printer
                }
                
                if let printer = self.printerCache[address] {
                    handler(printer)
                } else {
                    self.presentPrinterNotFoundAlertController()
                }
            }
        }
    }
    
    private func sendPrintData(printData: PrintData, toPrinterWithMACAddress address: String) {
        getPrinterWithMACAddress(address) { (printer: Printer) in
            printer.connect { (connected: Bool) in
                if connected {
                    printer.print(printData)
                } else {
                    let connectionFailureAlertController = UIAlertController(title: "Printer Connection Failure", message: nil, preferredStyle: .Alert)
                    
                    let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                    connectionFailureAlertController.addAction(okayAction)
                    
                    // FIXME: This does not work
                    UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(connectionFailureAlertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Receipt printing
    
    func printReceiptForOrder(order: Order) {
        if let address = ReceiptPrinterManager.receiptPrinterMACAddress() {
            
            let isCardPayment = order.payment!.cardFlightChargeToken != nil
            
            // Synchronously fetch restaurant for header information
            let defaultRestuarant = Restaurant.defaultRestaurantFromLocalDatastoreFetchIfNil()!
            
            var dictionary = [
                "{{copy}}": "Customer Copy",
                "{{restaurant}}": defaultRestuarant.name,
                "{{location}}": defaultRestuarant.location,
                "{{phone}}": defaultRestuarant.phone,
                "{{time}}": dateFormatter.stringFromDate(NSDate()),
                "{{server}}": order.server.name,
                "{{order_id}}": order.objectId!,
                "{{payment_id}}": order.payment!.objectId!,
                "{{subtotal}}": currencyNumberFormatter.stringFromDouble(order.subtotal)!
            ]

            if isCardPayment {
                dictionary["{{last_four}}"] = order.payment!.cardLastFour!
                dictionary["{{cardholder}}"] = order.payment!.cardName!
            } else {
                dictionary["{{cash_amount_paid}}"] = currencyNumberFormatter.stringFromDouble(order.payment!.cashAmountPaid)
                dictionary["{{change_given}}"] = currencyNumberFormatter.stringFromDouble(order.payment!.changeGiven)
            }
            
            let filePath = NSBundle.mainBundle().pathForResource("\(order.payment!.type.lowercaseString)_receipt_template", ofType: "xml")
            
            let printData = PrintData(dictionary: dictionary, atFilePath: filePath)
            
            ReceiptPrinterManager.sharedManager.sendPrintData(printData, toPrinterWithMACAddress: address)
            
            if isCardPayment {
                dictionary["{{copy}}"] = "Merchant Copy"
                let printData = PrintData(dictionary: dictionary, atFilePath: filePath)
                ReceiptPrinterManager.sharedManager.sendPrintData(printData, toPrinterWithMACAddress: address)
            }
        } else {
            presentPrinterNotFoundAlertController()
        }
    }
    
    // MARK: - Check printing
    
    func printCheckForOrderItems(orderItems: [OrderItem], party: Party) {
        if let address = ReceiptPrinterManager.receiptPrinterMACAddress() {
            
            let checkTemplateFilePath = NSBundle.mainBundle().pathForResource("check_template", ofType: "xml")
            
            // Synchronously fetch restaurant for header information
            let defaultRestuarant = Restaurant.defaultRestaurantFromLocalDatastoreFetchIfNil()!
            
            // Stitch together template language for each order item
            var orderItemsXML = ""
            for orderItem in orderItems {
                
                let itemName = orderItem.menuItem.name
                let price = currencyNumberFormatter.stringFromDouble(orderItem.itemCost())!
                
                orderItemsXML += "<left><text>\(itemName)</text></left><newline /><right><text>\(price)</text></right><newline />"
            }
            
            println(orderItemsXML)
            
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
                "{{table}}": party.table.name,
                "{{server}}": party.server.name,
                "{{items}}": orderItemsXML,
                "{{amount_due}}": currencyNumberFormatter.stringFromNumber(NSNumber(double: amountDue))!,
                "{{tax}}": currencyNumberFormatter.stringFromNumber(NSNumber(double: tax))!,
                "{{subtotal}}": currencyNumberFormatter.stringFromNumber(NSNumber(double: subtotal))!
            ]
            
            let printData = PrintData(dictionary: dictionary, atFilePath: checkTemplateFilePath)
            
            ReceiptPrinterManager.sharedManager.sendPrintData(printData, toPrinterWithMACAddress: address)
        } else {
            presentPrinterNotFoundAlertController()
        }
    }
    
    // MARK: - Kitchen printing
    
    func printOrderItems(orderItems: [OrderItem], party: Party?, createdBy: Employee?, toGo : Bool) {
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
        
        for printerAddress in printerMACAddressToPrintJobsMap.keys.array {
            var dictionary = [
                "{{location}}": toGo ? "To Go" : "Dine-In",
                "{{time}}": dateFormatter.stringFromDate(NSDate()),
                "{{table}}": party != nil ? party!.table.name : "",
                "{{server}}": party != nil ? party!.server.name : createdBy!.name,
            ]
            
            var menuItemsTemplate = ""
            
            let printJobsForPrinter = printerMACAddressToPrintJobsMap[printerAddress]!
            
            println("PRINT JOBS FOR PRINTER: \(printJobsForPrinter)")
            
            for printJob in printJobsForPrinter {
                let orderItem = printJobObjectIdToOrderItemMap[printJob.objectId!]!
                
                let menuItemXML = "<text><left><large>" + (printJob.text.isEmpty ? orderItem.menuItem.name : printJob.text) + "</large></left></text><newline />"
     
                let seatXML = orderItem.seatNumber == 0 ? "" : "<tab /><text><large>+ SEAT: \(orderItem.seatNumber)</large></text><newline />"
                
                var modsXML = ""
                if !orderItem.menuItemModifiers.isEmpty {
                    modsXML = orderItem.menuItemModifiers.reduce("") {
                        (previous, modifier) in
                        return "\(previous)<tab /><text><large><ic>+ \(modifier.name)</ic></large></text><newline />"
                    }
                }
                
                let notesXML = orderItem.notes.isEmpty ? "" : "<tab /><text><large><ic>+ \(orderItem.notes)</ic></large></text><newline />"
                
                let menuItemTemplate = menuItemXML + seatXML + modsXML + notesXML
                menuItemsTemplate += menuItemTemplate
            }
            
            dictionary["{{menu_items}}"] = menuItemsTemplate
            
            let orderItemTemplateFilePath = NSBundle.mainBundle().pathForResource("order_item_template", ofType: "xml")
            let printData = PrintData(dictionary: dictionary, atFilePath: orderItemTemplateFilePath)
            
            ReceiptPrinterManager.sharedManager.sendPrintData(printData, toPrinterWithMACAddress: printerAddress)
        }
    }
    
    func printDailySummaryForServer(server: Employee, date: NSDate) {
        if let address = ReceiptPrinterManager.receiptPrinterMACAddress() {
            let query = Order.query()!
            query.includeKey("payment")
            
            query.whereKey("createdAt", greaterThanOrEqualTo: NSCalendar.currentCalendar().startOfDayForDate(date))
            query.whereKey("createdAt", lessThan: NSCalendar.currentCalendar().endOfDayForDate(date))
            
            query.whereKeyExists("payment")
            
            let innerQuery = Payment.query()!
            innerQuery.whereKey("charged", equalTo: true)
            query.whereKey("payment", matchesQuery: innerQuery)
            
            let orders = query.findObjects() as! [Order]
            
            var ordersTemplate = orders.reduce("") {
                (previous, order) in
                let orderID = order.objectId!
                let paymentType = order.payment!.type
                let subtotal = currencyNumberFormatter.stringFromDouble(order.subtotal)!
                let tip = currencyNumberFormatter.stringFromDouble(order.tip)!
                return "\(previous)<text>Order ID: \(orderID)</text><newline /><tab><text>Payment Type: \(paymentType)</text><newline /><tab><text>Subtotal: \(subtotal)</text><newline /><tab><text>Tip: \(tip)</text><newline /><newline />"
            }
            
            let cardTotal = orders.reduce(0) {
                (total, order) in
                return total + (order.payment!.type == "Card" ? order.subtotal : 0)
            }
            let cashTotal = orders.reduce(0) {
                (total, order) in
                return total + (order.payment!.type == "Cash" ? order.subtotal : 0)
            }
            let tips = orders.reduce(0) {
                (total, order) in
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
            
            let printData = PrintData(dictionary: dictionary, atFilePath: NSBundle.mainBundle().pathForResource("server_summary_template", ofType: "xml"))
            
            ReceiptPrinterManager.sharedManager.sendPrintData(printData, toPrinterWithMACAddress: address)
            
        } else {
            presentPrinterNotFoundAlertController()
        }
    }
    
}
