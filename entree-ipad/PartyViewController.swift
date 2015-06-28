
import UIKit

class PartyViewController: PFQueryTableViewController {
    
    @IBAction func closeTable(sender: UIBarButtonItem) {
        let confirmationAlertController = UIAlertController(title: "Close Table?", message: "You will no longer be able to access this party's orders or payment methods (This final checkout process will take place on the Overview panel).", preferredStyle: .Alert)
        
        confirmationAlertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        confirmationAlertController.addAction(UIAlertAction(title: "Close Table?", style: .Destructive) { (action: UIAlertAction!) in
            self.party.leftAt = NSDate()
            self.party.table.currentParty = nil
            
            PFObject.saveAllInBackground([self.party, self.party.table]) { (succeeded: Bool, error: NSError?) in
                if succeeded {
                    self.dismiss(sender)
                } else {
                    println(error?.localizedDescription)
                }
            }
        })
        
        presentViewController(confirmationAlertController, animated: true, completion: nil)
    }
    
    @IBAction func createPayment(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Sorry!", message: "This function is temporarily disabled for demonstration purposes.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func dismiss(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func printBill(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Sorry!", message: "This function is temporarily disabled for demonstration purposes.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBOutlet var createPaymentButton: UIButton!
    @IBOutlet var timeSeatedLabel: UILabel!
    
    var orders: [Order] {
        return objects! as! [Order]
    }
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
    
    private func orderAtIndexPath(indexPath: NSIndexPath) -> Order? {
        return orders.filter { (order: Order) -> Bool in return order.seat == indexPath.section }[indexPath.row]
    }
    
    // MARK: - PFQueryTableViewController
    
    override func queryForTable() -> PFQuery {
        let query = Order.query()!
        query.limit = 1000
        
        query.includeKey("menuItem")

        query.orderByAscending("createdAt")
        
        query.whereKey("party", equalTo: party)
        
        return query
    }
    
    // MARK: - UIViewController
    
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
        for order in orders { seatSeen[order.seat] = true }
        return seatSeen.keys.array.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        let order = orderAtIndexPath(indexPath)!
        
        let price = numberFormatter.stringFromNumber(NSNumber(double: order.menuItem.price))!
        cell.textLabel?.text = "\(order.menuItem.name) [\(price)]"
        cell.detailTextLabel!.text = order.notes
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.filter { (order: Order) -> Bool in return order.seat == section }.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Table" : "Seat \(section)"
    }
    
}
