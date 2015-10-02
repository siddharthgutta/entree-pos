
import UIKit

class OrderItemsViewController: PFQueryTableViewController {
    
    @IBAction func closeTable() {
        if objects!.isEmpty {
            let confirmationAlertController = UIAlertController(title: "Close Table?", message: "You will no longer be able to place orders for this party (The final checkout process, including tip, will take place in the Orders panel).", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            confirmationAlertController.addAction(cancelAction)
            
            let closeAction = UIAlertAction(title: "Close", style: .Destructive) { (action: UIAlertAction!) in
                var objectsToSave = [AnyObject]()
                
                self.party.leftAt = NSDate()
                objectsToSave.append(self.party)
                
                self.party.server.incrementKey("activePartyCount", byAmount: NSNumber(integer: -1))
                objectsToSave.append(self.party.server)
                
                if let table = self.party.table {
                    table.currentParty = nil
                    objectsToSave.append(table)
                }
                
                PFObject.saveAllInBackground(objectsToSave) { success, error in
                    if success {
                        self.dismiss()
                    } else {
                        self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
                    }
                }
            }
            confirmationAlertController.addAction(closeAction)
            
            presentViewController(confirmationAlertController, animated: true, completion: nil)
        } else {
            let unpaidItemsAlertController = UIAlertController(title: "Oops!", message: "You can not close this table without providing a method of payment for each item. First select the remaining items by tapping them, then press the green button in the toolbar to set the payment method.", preferredStyle: .Alert)
            
            let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            unpaidItemsAlertController.addAction(okayAction)
            
            presentViewController(unpaidItemsAlertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func pay(sender: UIBarButtonItem) {
        let selectPaymentTypeAlertController = UIAlertController(title: "Select Payment Type", message: nil, preferredStyle: .ActionSheet)
        
        let cardAction = UIAlertAction(title: "Card", style: .Default) { (action: UIAlertAction!) in
            self.createOrderWithSelectedOrderItemsAndPerformSegueWithIdentifier("CardPayment")
        }
        selectPaymentTypeAlertController.addAction(cardAction)
        
        let cashAction = UIAlertAction(title: "Cash", style: .Default) { (action: UIAlertAction!) in
            self.createOrderWithSelectedOrderItemsAndPerformSegueWithIdentifier("CashPayment")
        }
        selectPaymentTypeAlertController.addAction(cashAction)
        
        selectPaymentTypeAlertController.modalPresentationStyle = .Popover
        
        presentViewController(selectPaymentTypeAlertController, animated: true, completion: nil)

        selectPaymentTypeAlertController.popoverPresentationController?.barButtonItem = sender
    }
    
    @IBAction func dismiss() {
        presentingViewController?.dismissViewControllerAnimated(true) { () in
            NSNotificationCenter.defaultCenter().postNotificationName(LOAD_OBJECTS_NOTIFICATION, object: nil)
        }
    }
    
    @IBAction func printCheck() {
        let items = orderItemsForSelectedRows()
        
        if items.isEmpty {
            presentNoItemsSelectedAlertController()
        } else {
            PrintingManager.sharedManager().printCheckForOrderItems(items, party: party)
            
            for item in items {
                item.printedToCheck = true
            }
            
            PFObject.saveAllInBackground(items) { (success: Bool, error: NSError?) in
                if success {
                    self.loadObjects()
                } else {
                    self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func printOrderItems() {
        let items = orderItemsForSelectedRows()
        
        if items.isEmpty {
            presentNoItemsSelectedAlertController()
        } else {
            PrintingManager.sharedManager().printPrintJobsForOrderItems(items, party: party, server: party.server, toGo: false)
            
            for item in items {
                item.sentToKitchen = true
            }
            
            PFObject.saveAllInBackground(items) { (success: Bool, error: NSError?) in
                if success {
                    self.loadObjects()
                } else {
                    self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBOutlet weak var seatedAtLabel: UILabel!
    @IBOutlet weak var itemsSelectedLabel: UILabel!
    @IBOutlet weak var amountDueLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    
    var party: Party!
    
    var currencyNumberFormatter: NSNumberFormatter {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        return formatter
    }
    var dateFormatter: NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        return formatter
    }
    
    // MARK: - OrderItemsViewController
    
    func configureView() {
        // Navigation Title
        navigationItem.title = party.customerTab ? party.name : party.table?.name
        
        // Table Header View
        if let seatedAt = party.seatedAt {
            seatedAtLabel.text = "Seated at " + dateFormatter.stringFromDate(seatedAt)
        } else {
            let now = NSDate()
            party.seatedAt = now
            party.saveEventually()
            seatedAtLabel.text = "Seated at " + dateFormatter.stringFromDate(now)
        }
        
        // Table Footer View
        let selectedOrderItems = orderItemsForSelectedRows()
        
        itemsSelectedLabel.text = "\(selectedOrderItems.count) Items Selected"
        
        let amountDue = selectedOrderItems.reduce(0) { (amountDue: Double, item: OrderItem) -> Double in
            return amountDue + item.itemCost()
        }
        let tax = selectedOrderItems.reduce(0) { (tax: Double, item: OrderItem) -> Double in
            return tax + item.applicableTax()
        }
        
        amountDueLabel.text = "Amount Due: " + currencyNumberFormatter.stringFromDouble(amountDue)!
        taxLabel.text = "Tax: " + currencyNumberFormatter.stringFromDouble(tax)!
        subtotalLabel.text = "Subtotal: " + currencyNumberFormatter.stringFromDouble(amountDue + tax)!
    }
    
    private func createOrderWithSelectedOrderItemsAndPerformSegueWithIdentifier(identifier: String) {
        let selectedOrderItems = orderItemsForSelectedRows()
        
        let order = Order.createOrderWithType("Full Service", name: nil, party: party, orderItems: selectedOrderItems)
        
        let objectsToSave: [AnyObject] = selectedOrderItems + [order]
        
        PFObject.saveAllInBackground(objectsToSave) { (succeeded: Bool, error: NSError?) in
            if succeeded {
                self.performSegueWithIdentifier(identifier, sender: order)
            } else {
                self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
            }
        }
    }
    
    private func orderItemsForSelectedRows() -> [OrderItem] {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            let orderItems = indexPaths.map {
                (indexPath: NSIndexPath) -> OrderItem in
                
                return self.objectAtIndexPath(indexPath) as! OrderItem
            }
            return orderItems
        } else {
            return []
        }
    }
    
    private func presentNoItemsSelectedAlertController() {
        let noItemsSelectedAlertController = UIAlertController(title: "No Items Selected", message: nil, preferredStyle: .Alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        noItemsSelectedAlertController.addAction(okayAction)
        
        presentViewController(noItemsSelectedAlertController, animated: true, completion: nil)
    }

    // MARK: - PFQueryTableViewController

    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        
        configureView()
    }
    
    override func queryForTable() -> PFQuery {
        let query = OrderItem.query()!
        query.limit = 1000
        
        query.includeKey("menuItem")
        query.includeKey("menuItem.menuCategory")
        query.includeKey("menuItem.menuCategory.menu")
        query.includeKey("menuItem.printJobs")
        query.includeKey("menuItem.printJobs.printer")
        query.includeKey("menuItemModifiers")
        
        query.whereKey("party", equalTo: party)
        
        query.whereKeyDoesNotExist("order")
        
        return query
    }
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OrderItemDetail" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let orderItemDetailViewController = navigationController.viewControllers.first as! OrderItemDetailViewController
            
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            orderItemDetailViewController.orderItem = objectAtIndexPath(indexPath) as! OrderItem
        } else if segue.identifier == "CardPayment" {
            let navController = segue.destinationViewController as! UINavigationController
            let cardPaymentViewController = navController.viewControllers.first as! CardPaymentViewController
            cardPaymentViewController.order = sender as! Order
            cardPaymentViewController.completionHandler = {
                cardPaymentViewController.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                
                NSNotificationCenter.defaultCenter().postNotificationName(LOAD_OBJECTS_NOTIFICATION, object: nil)
            }
        } else if segue.identifier == "CashPayment" {
            let navController = segue.destinationViewController as! UINavigationController
            let cashPaymentViewController = navController.viewControllers.first as! CashPaymentViewController
            cashPaymentViewController.order = sender as! Order
            cashPaymentViewController.completionHandler = {
                cashPaymentViewController.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                
                NSNotificationCenter.defaultCenter().postNotificationName(LOAD_OBJECTS_NOTIFICATION, object: nil)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loadObjects"), name: LOAD_OBJECTS_NOTIFICATION, object: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let orderItem = objectAtIndexPath(indexPath) as! OrderItem
        return !orderItem.sentToKitchen
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OrderItemCell", forIndexPath: indexPath) 

        let orderItem = objectAtIndexPath(indexPath) as! OrderItem
        
        cell.textLabel?.text = orderItem.menuItem.name + (orderItem.seatNumber == 0 ? "" : " (Seat: \(orderItem.seatNumber))")
        cell.detailTextLabel?.text = orderItem.menuItemModifiers.reduce("") {
            (previous, modifier) in
            return "\(previous)\(modifier.name); "
        } + orderItem.notes
        
        cell.imageView?.image = nil
        if orderItem.sentToKitchen {
            cell.imageView?.image = UIImage(named: "Paper Airplane")
        }
        if orderItem.printedToCheck {
            cell.imageView?.image = UIImage(named: "Printer")
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            removeObjectAtIndexPath(indexPath)
            configureView()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        configureView()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        configureView()
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Remove"
    }
    
}
