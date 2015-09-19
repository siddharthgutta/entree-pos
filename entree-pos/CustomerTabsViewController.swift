
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
            let textField = newCustomerTabAlertController.textFields!.first as! UITextField
            
            self.addOrderWithName(textField.text)
        }
        newCustomerTabAlertController.addAction(addAction)
        
        presentViewController(newCustomerTabAlertController, animated: true, completion: nil)
    }
    
    var server: Employee!
    
    // MARK: - CustomerTabsViewController
    
    private func addOrderWithName(name: String) {
        let order = Order()
        
        order.installation = PFInstallation.currentInstallation()
        order.name = name
        order.restaurant = Restaurant.defaultRestaurantFromLocalDatastoreFetchIfNil()!
        order.type = "Customer Tab"
        
        order.orderItems = []
        
        order.server = server
        
        order.saveInBackgroundWithBlock {
            (succeeded, error) in
            
            if succeeded {
                self.loadObjects()
            } else {
                self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
            }
        }
        
    }
    
    // MARK: - PFQueryTableViewController
    
    override func queryForTable() -> PFQuery {
        let query = Order.query()!
        query.limit = 1000
        
        query.whereKey("restaurant", equalTo: Restaurant.defaultRestaurantFromLocalDatastoreFetchIfNil()!)
        query.whereKey("server", equalTo: server)
        query.whereKey("type", equalTo: "Customer Tab")
        query.whereKeyDoesNotExist("payment")
        
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomerTabCell", forIndexPath: indexPath) as! PFTableViewCell
        
        let order = object as! Order
        
        cell.textLabel?.text = order.name
        
        return cell
    }
    
    // MARK: - UIViewController
    
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
            removeObjectAtIndexPath(indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let quickServiceSplitViewController = UIStoryboard(name: "QuickService", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! UISplitViewController
        let navController = quickServiceSplitViewController.viewControllers.first as! UINavigationController
        let quickServiceOrderViewController = navController.viewControllers.first as! QuickServiceOrderViewController
        quickServiceOrderViewController.order = objectAtIndexPath(indexPath) as! Order
        
        presentViewController(quickServiceSplitViewController, animated: true, completion: nil)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
