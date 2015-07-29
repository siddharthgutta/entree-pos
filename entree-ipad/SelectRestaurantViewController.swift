
import UIKit

class SelectRestaurantViewController: PFQueryTableViewController {

    // MARK: - PFQueryTableViewController
    
    override func queryForTable() -> PFQuery {
        let restaurantsRelation = PFUser.currentUser()!.relationForKey("restaurants")
        let query = restaurantsRelation.query()!
        
        query.limit = 1000
        
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PFTableViewCell
        
        cell.textLabel?.text = object?["name"] as? String
        cell.detailTextLabel?.text = object?["location"] as? String
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let restaurant = objectAtIndexPath(indexPath)
        
        NSUserDefaults.standardUserDefaults().setObject(restaurant!.objectId!, forKey: "default_restaurant")
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
