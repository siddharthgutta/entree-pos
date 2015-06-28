
import UIKit

class ServerOverviewViewController: PFQueryTableViewController {

    @IBAction func dismiss(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func nextDate(sender: UIButton) {
        changeDateWithValue(1)
    }
    
    @IBAction func previousDate(sender: UIButton) {
        changeDateWithValue(-1)
    }
    
    @IBOutlet var dateLabel: UILabel!
    
    var date = NSDate()
    let dateFormatter = NSDateFormatter()
    var server: Employee?
    
    // MARK: - Initializer
    
    required init(coder aDecoder: NSCoder!) {
        dateFormatter.dateStyle = .FullStyle
        dateFormatter.timeStyle = .ShortStyle
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - ServerOverviewViewController
    
    func changeDateWithValue(value: Int) {
        date = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: value, toDate: date, options: nil)!
        
        dateFormatter.dateStyle = .FullStyle
        dateFormatter.timeStyle = .NoStyle
        dateLabel.text = dateFormatter.stringFromDate(date)
        
        loadObjects()
    }
    
    // MARK: - PFQueryTableViewController
    
    override func queryForTable() -> PFQuery {
        let query = Party.query()!
        query.cachePolicy = .CacheThenNetwork
        query.limit = 1000

        query.includeKey("table")
        
        query.whereKey("seatedAt", greaterThanOrEqualTo: NSCalendar.currentCalendar().startOfDayForDate(date))
        query.whereKey("seatedAt", lessThan: NSCalendar.currentCalendar().endOfDayForDate(date))
        
        query.whereKey("server", equalTo: server!)
        
        query.whereKeyExists("leftAt")
        
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PFTableViewCell
        
        let party = object! as! Party
        
        var name = party.table.name
        if !party.name.isEmpty {
            name = "\(party.name) Party, \(name)"
        }
        cell.textLabel?.text = name
        
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle
        cell.detailTextLabel?.text = "Arrived at " + dateFormatter.stringFromDate(party.arrivedAt) + ", Seated at " + dateFormatter.stringFromDate(party.seatedAt) + ", Left at " + dateFormatter.stringFromDate(party.leftAt)
        
        return cell
    }
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "Payments":
            if let partyPaymentsViewController = segue.destinationViewController as? PartyPaymentsViewController {
                partyPaymentsViewController.party = objectAtIndexPath(tableView.indexPathForCell(sender as! UITableViewCell)) as? Party
            }
        default:
            println(UNRECOGNIZED_SEGUE_IDENTIFIER_ERROR_MESSAGE)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        date = NSDate()
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alertController = UIAlertController(title: "Sorry!", message: "This function is temporarily disabled for demonstration purposes.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
        presentViewController(alertController, animated: true) { () in
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
}
