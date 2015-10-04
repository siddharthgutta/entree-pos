
import UIKit

class ServerOverviewViewController: PFQueryTableViewController {

    @IBAction func printSummary(sender: UIButton) {
        PrintingManager.sharedManager().printSummaryForServer(server, date: date, fromViewController: self)
    }
    
    @IBAction func dismiss(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func nextDate(sender: UIButton) {
        changeDayByAddingValue(1)
    }
    
    @IBAction func previousDate(sender: UIButton) {
        changeDayByAddingValue(-1)
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    
    var date = NSDate()
    let dateFormatter = NSDateFormatter()
    var server: Employee!
    
    // MARK: - Initializer
    
    required init(coder aDecoder: NSCoder) {
        dateFormatter.dateStyle = .FullStyle
        dateFormatter.timeStyle = .ShortStyle
        
        super.init(coder: aDecoder)!
        
        objectsPerPage = 1000
    }
    
    // MARK: - ServerOverviewViewController
    
    func changeDayByAddingValue(value: Int) {
        date = date.dateByAddingTimeInterval(86400 * Double(value))
        
        dateFormatter.dateStyle = .FullStyle
        dateFormatter.timeStyle = .NoStyle
        dateLabel.text = dateFormatter.stringFromDate(date)
        
        loadObjects()
    }
    
    // MARK: - PFQueryTableViewController
    
    override func queryForTable() -> PFQuery {
        let query = Order.query()!

        query.includeKey("payment")
        query.whereKeyExists("payment")
        
        query.whereKey("createdAt", greaterThanOrEqualTo: NSCalendar.currentCalendar().startOfDayForDate(date))
        query.whereKey("createdAt", lessThan: NSCalendar.currentCalendar().endOfDayForDate(date))
        
        if server.administrator == true {
            query.whereKey("restaurant", equalTo: Restaurant.defaultRestaurantFromLocalDatastoreFetchIfNil()!)
        } else {
            query.whereKey("server", equalTo: server)
        }
        
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("OrderCell", forIndexPath: indexPath) as! PFTableViewCell
        
        let order = object! as! Order
        
        var employeeText = ""
        if server.administrator {
            employeeText = ", \(order.server.name)"
        }
        let prefix = order.payment!.charged && order.payment!.type == "Card" ? " (Charged)" : ""
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .CurrencyStyle
        cell.textLabel?.text = "\(numberFormatter.stringFromDouble(order.total)!), \(order.payment!.type)\(prefix), Order ID: \(order.objectId!)\(employeeText)"
        
        if order.payment!.charged && order.payment!.type == "Card" {
            cell.textLabel?.textColor = .entreeGreenColor()
        } else {
            cell.textLabel?.textColor = .blackColor()
        }
        
        if order.payment!.type == "Card" {
            cell.accessoryType = .DisclosureIndicator
        } else {
            cell.accessoryType = .None
        }
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.timeStyle = .ShortStyle
        cell.detailTextLabel?.text = timeFormatter.stringFromDate(order.createdAt!)
        
        return cell
    }
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CardCompletion" {
            let cardPaymentOrderCompletionViewController = segue.destinationViewController as! CardPaymentOrderCompletionViewController
            cardPaymentOrderCompletionViewController.order = sender as! Order
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        changeDayByAddingValue(0)
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let order = objectAtIndexPath(indexPath) as! Order
        
        if order.payment?.type == "Card" {
            performSegueWithIdentifier("CardCompletion", sender: order)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
