
import UIKit

class MenuItemModifierListViewController: PFQueryTableViewController {

    var order: Order?
    
    let numberFormatter = NSNumberFormatter()
    
    // MARK: - PFQueryTableViewController
    
    override func queryForTable() -> PFQuery {
        let query = MenuItemModifier.query()!
        
        query.orderByAscending("name")
        
        query.whereKey("menuItems", equalTo: order!.menuItem)
        query.whereKey("objectId", notContainedIn: order!.menuItemModifiers.map { (menuItemModifier: MenuItemModifier) -> String in return menuItemModifier.objectId! })
        
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PFTableViewCell
        
        let menuItemModifier = objectAtIndexPath(indexPath)! as! MenuItemModifier
        
        cell.textLabel?.text = menuItemModifier.name
        cell.detailTextLabel?.text = numberFormatter.stringFromNumber(NSNumber(double: menuItemModifier.price))
        
        return cell
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberFormatter.numberStyle = .CurrencyStyle
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let menuItemModifier = objectAtIndexPath(indexPath)! as! MenuItemModifier
        order?.menuItemModifiers.append(menuItemModifier)
        
        order?.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) in
            if succeeded {
                NSNotificationCenter.defaultCenter().postNotificationName(LOAD_OBJECTS_NOTIFICATION, object: nil)
                
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                println(error?.localizedDescription)
            }
        }
    }
    
}
