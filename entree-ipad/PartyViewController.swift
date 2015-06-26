
import UIKit

class PartyViewController: PFQueryTableViewController {
    
    @IBAction func closeTable(sender: UIBarButtonItem) {
        
    }
    
    @IBAction func createPayment(sender: UIBarButtonItem) {
        
    }
    
    @IBAction func dismiss(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func printBill(sender: UIBarButtonItem) {
        
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
        cell.textLabel!.text = "\(order.menuItem.name) [\(price)]"
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
