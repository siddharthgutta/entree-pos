
import UIKit

class PartyViewController: PFQueryTableViewController {
    
    @IBAction func createPayment(sender: UIButton) {
        
    }
    
    @IBAction func dismiss(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func printBill(sender: UIButton) {
        
    }
    
    @IBOutlet var checkoutButton: UIButton!
    @IBOutlet var timeSeatedLabel: UILabel!
    
    var numberOfSeats: Int {
        var greatest = 0
        for order in orders {
            if order.seat > greatest {
                greatest = order.seat
            }
        }
        return greatest + 1
    }
    var orders: [Order] {
        return self.objects! as! [Order]
    }
    var party: Party!
    
    let dateComponentsFormatter = NSDateComponentsFormatter()
    let numberFormatter = NSNumberFormatter()

    // MARK: - Initializer
    
    required init(coder aDecoder: NSCoder) {
        dateComponentsFormatter.unitsStyle = .Abbreviated
        numberFormatter.numberStyle = .CurrencyStyle
        
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loadObjects"), name: LOAD_OBJECTS_NOTIFICATION, object: nil)
    }
    
    // MARK: - PartyViewController
    
    func ordersForSection(section: Int) -> [Order] {
        return orders.filter { (order: Order) -> Bool in
            return order.seat == section
        }
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
        
        navigationItem.title = party.table.name
        
        let unitFlags: NSCalendarUnit = .CalendarUnitHour | .CalendarUnitMinute
        let dateComponents = NSCalendar.currentCalendar().components(unitFlags, fromDate: party.seatedAt, toDate: NSDate(), options: nil)
        timeSeatedLabel.text = "Seated for " + dateComponentsFormatter.stringFromDateComponents(dateComponents)!
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numberOfSeats
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        let order = objectAtIndexPath(indexPath)! as! Order
        
        let price = numberFormatter.stringFromNumber(NSNumber(double: order.menuItem.price))!
        cell.textLabel!.text = "\(order.menuItem.name) [\(price)]"
        cell.detailTextLabel!.text = order.notes
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ordersForSection(section).count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? nil : "Seat \(section)"
    }
    
}
