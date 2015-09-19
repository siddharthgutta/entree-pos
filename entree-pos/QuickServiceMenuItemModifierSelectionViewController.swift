
import UIKit

class QuickServiceMenuItemModifierSelectionViewController: PFQueryTableViewController {
    
    var orderItem: OrderItem!
    
    // MARK: - QuickServiceMenuItemModifierSelectionViewController
    
    private func orderItemContainsMenuItemModifier(modifier: MenuItemModifier) -> Bool {
        for menuItemModifier in orderItem.menuItemModifiers {
            if menuItemModifier.objectId! == modifier.objectId! {
                return true
            }
        }
        return false
    }
    
    private func removeMenuItemModifierFromOrderItem(modifierToRemove: MenuItemModifier) {
        var index = 0
        for modifier in orderItem.menuItemModifiers {
            if modifier.objectId! == modifierToRemove.objectId! {
                orderItem.menuItemModifiers.removeAtIndex(index)
            }
            index++
        }
    }
    
    // MARK: - PFQueryTableViewController
    
    override func queryForTable() -> PFQuery {
        let query = MenuItemModifier.query()!
        
        query.orderByAscending("name")
        
        query.whereKey("menuItems", equalTo: orderItem.menuItem)
        
        return query
    }
 
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuItemModifierCell", forIndexPath: indexPath) as! PFTableViewCell
        
        let menuItemModifier = object as! MenuItemModifier
        
        cell.textLabel?.text = menuItemModifier.name
        cell.accessoryType = orderItemContainsMenuItemModifier(menuItemModifier) ? .Checkmark : .None
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let menuItemModifier = objectAtIndexPath(indexPath) as! MenuItemModifier
        
        if orderItemContainsMenuItemModifier(menuItemModifier) {
            removeMenuItemModifierFromOrderItem(menuItemModifier)
        } else {
            orderItem.menuItemModifiers.append(menuItemModifier)
        }
        
        loadObjects()
    }
    
}