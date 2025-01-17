
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
        
        cell.textLabel?.text = object?.valueForKey("name") as? String
        cell.detailTextLabel?.text = object?.valueForKey("location") as? String
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let restaurant = objectAtIndexPath(indexPath) as! Restaurant
        
        // Set default restaurant object ID
        NSUserDefaults.standardUserDefaults().setObject(restaurant.objectId!, forKey: "default_restaurant")
        
        // Set CardFlight API token
        CFTSessionManager.sharedInstance().setApiToken(CARDFLIGHT_PRODUCTION_API_KEY, accountToken: restaurant.cardFlightAccountToken)
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
