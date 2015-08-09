
import UIKit

class OrderItemsViewController: PFQueryTableViewController {
    
    @IBAction func closeTable(sender: UIBarButtonItem) {
        let confirmationAlertController = UIAlertController(title: "Close Table?", message: "You will no longer be able to access this party's orders or payment methods (This final checkout process will take place on the Overview panel).", preferredStyle: .Alert)
        
        confirmationAlertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        confirmationAlertController.addAction(UIAlertAction(title: "Close Table?", style: .Destructive) { (action: UIAlertAction!) in
            self.party.leftAt = NSDate()
            self.party.table.currentParty = nil
            
            PFObject.saveAllInBackground([self.party, self.party.table]) { (succeeded: Bool, error: NSError?) in
                if succeeded {
                    self.dismiss()
                } else {
                    println(error?.localizedDescription)
                }
            }
        })
        
        presentViewController(confirmationAlertController, animated: true, completion: nil)
    }
    
    @IBAction func dismiss() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func printOrderItems() {
        println("0")
        
        if let indexPaths = tableView.indexPathsForSelectedRows() as? [NSIndexPath] {
            println("1")
            
            let orderItems = indexPaths.map { (indexPath: NSIndexPath) -> OrderItem in return self.orderItemAtIndexPath(indexPath)! }
            
            if orderItems.isEmpty {
                println("2")
                
                presentNoOrdersSelectedAlertController()
            } else {
                
                println("3")
                ReceiptPrinterManager.sharedManager().printOrderItems(orderItems)
            }
        } else {
            presentNoOrdersSelectedAlertController()
        }
    }
    
    @IBOutlet var timeSeatedLabel: UILabel!
    
    var orderItems: [OrderItem] { return objects! as! [OrderItem] }
    var party: Party! 
    
    let dateComponentsFormatter = NSDateComponentsFormatter()
    let numberFormatter = NSNumberFormatter()

    // MARK: - Initializer
    
    required init(coder aDecoder: NSCoder) {
        dateComponentsFormatter.unitsStyle = .Full
        numberFormatter.numberStyle = .CurrencyStyle
        
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loadObjects"), name: LOAD_OBJECTS_NOTIFICATION, object: nil)
    }
    
    // MARK: - PartyViewController
    
    private func presentNoOrdersSelectedAlertController() {
        let noOrdersSelectedAlertController = UIAlertController(title: "No Orders Selected", message: nil, preferredStyle: .Alert)
        noOrdersSelectedAlertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
    }
    
    private func orderItemAtIndexPath(indexPath: NSIndexPath) -> OrderItem? {
        return orderItems.filter { (orderItem: OrderItem) -> Bool in return orderItem.seatNumber == indexPath.section }[indexPath.row]
    }
    
    // MARK: - PFQueryTableViewController
    
    override func queryForTable() -> PFQuery {
        let query = OrderItem.query()!
        query.limit = 1000
        
        query.includeKey("menuItem")
        query.includeKey("menuItem.printJobs")
        query.includeKey("menuItem.printJobs.printer")
        query.includeKey("menuItemModifiers")

        query.orderByAscending("createdAt")
        
        query.whereKey("party", equalTo: party)
        
        query.whereKeyDoesNotExist("order")
        
        return query
    }
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "Order":
            if let navigationController = segue.destinationViewController as? UINavigationController,
            let orderViewController = navigationController.viewControllers.first as? OrderViewController {
                
                let selectedIndexPaths = tableView.indexPathsForSelectedRows() as! [NSIndexPath]
                let selectedOrderItems = selectedIndexPaths.map { (indexPath: NSIndexPath) -> OrderItem in return self.orderItemAtIndexPath(indexPath)! }
                
                let order = Order()
                order.orderItems = selectedOrderItems
                order.party = party
                
                for orderItem in selectedOrderItems { orderItem.order = order }
                
                let objectsToSave: [AnyObject] = orderItems + [order]
                PFObject.saveAll(objectsToSave)
                
                orderViewController.order = order
                
            }
        default:
            println()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var title = party.table.name
        if !party.name.isEmpty {
            title += " – \(party.name)"
        }
        navigationItem.title = title
        
        let unitFlags: NSCalendarUnit = .CalendarUnitHour | .CalendarUnitMinute
        let dateComponents = NSCalendar.currentCalendar().components(unitFlags, fromDate: party.seatedAt, toDate: NSDate(), options: nil)
        timeSeatedLabel.text = "Seated for " + dateComponentsFormatter.stringFromDateComponents(dateComponents)!
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var seatSeen = [Int: Bool]()
        for orderItem in orderItems {
            seatSeen[orderItem.seatNumber] = true
        }
        return seatSeen.keys.array.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! OrderTableViewCell
        
        if let orderItem = orderItemAtIndexPath(indexPath) {
            cell.menuItemNameLabel?.text = orderItem.menuItem.name
            cell.notesLabel?.text = orderItem.notes
            cell.priceLabel?.text = numberFormatter.stringFromNumber(NSNumber(double: orderItem.totalCost()))
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderItems.filter { (orderItem: OrderItem) -> Bool in return orderItem.seatNumber == section }.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Table" : "Seat \(section)"
    }
    
}
