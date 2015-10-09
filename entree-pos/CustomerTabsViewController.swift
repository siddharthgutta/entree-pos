
import UIKit

class CustomerTabsViewController: PFQueryTableViewController {

    @IBAction func add(sender: UIBarButtonItem) {
        let newCustomerTabAlertController = UIAlertController(title: "New Customer Tab", message: nil, preferredStyle: .Alert)
        
        newCustomerTabAlertController.addTextFieldWithConfigurationHandler {
            (textField) in
            textField.placeholder = "Name"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        newCustomerTabAlertController.addAction(cancelAction)
        
        let addAction = UIAlertAction(title: "Add", style: .Default) {
            (action) in
            let textField = newCustomerTabAlertController.textFields!.first!
            
            let party = Party.partyWithServer(self.server, table: nil, name: textField.text, size: 1, customerTab: true)
            party.saveInBackgroundWithBlock { successful, error in
                if successful {
                    self.loadObjects()
                } else {
                    self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
                }
            }
        }
        newCustomerTabAlertController.addAction(addAction)
        
        presentViewController(newCustomerTabAlertController, animated: true, completion: nil)
    }
    
    var server: Employee!
    
    // MARK: - PFQueryTableViewController
    
    override func queryForTable() -> PFQuery {
        let query = Party.query()!
        query.limit = 1000
        
        query.whereKey("restaurant", equalTo: Restaurant.defaultRestaurantFromLocalDatastoreFetchIfNil()!)
        query.whereKey("customerTab", equalTo: true)
        query.whereKeyDoesNotExist("leftAt")
        
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomerTabCell", forIndexPath: indexPath) as! PFTableViewCell
        
        let party = object as! Party
        
        cell.textLabel?.text = party.name
        
        return cell
    }
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Party" {
            if let splitViewController = segue.destinationViewController as? UISplitViewController,
                let navigationController = splitViewController.viewControllers.first as? UINavigationController,
                let orderItemsViewController = navigationController.viewControllers.first as? OrderItemsViewController {
                    orderItemsViewController.party = sender as! Party
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadObjects", name: LOAD_OBJECTS_NOTIFICATION, object: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let party = objectAtIndexPath(indexPath) as! Party
            party.leftAt = NSDate()
            party.saveInBackgroundWithBlock { saved, error in
                if saved {
                    self.tableView.reloadData() // This call is a workaround for a UIKit bug that breaks transitions and UITableView reloading (Do explore) 
                    self.loadObjects()
                } else {
                    self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("Party", sender: objectAtIndexPath(indexPath))
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Close"
    }
    
}
