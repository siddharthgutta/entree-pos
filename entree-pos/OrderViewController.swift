
import UIKit

class OrderViewController: PFQueryTableViewController {
    
    var order: Order?

    let numberFormatter = NSNumberFormatter.numberFormatterWithStyle(.CurrencyStyle)
    
    // MARK: - PFQueryTableViewController
    
    override func queryForTable() -> PFQuery {
        let query = OrderItem.query()!
        query.limit = 1000
        
        query.includeKey("menuItem")
        
        query.orderByAscending("createdAt")
        
        return query
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch indexPath.section {
        case 0:
            let orderItem = objectAtIndexPath(indexPath) as! OrderItem
            
            cell = tableView.dequeueReusableCellWithIdentifier("OrderItemCell", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = orderItem.menuItem.name
            cell.detailTextLabel?.text = numberFormatter.stringFromNumber(NSNumber(double: orderItem.totalCost()))
        case 1:
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCellWithIdentifier("SubtotalCell", forIndexPath: indexPath) as! UITableViewCell
                cell.detailTextLabel?.text = numberFormatter.stringFromNumber(NSNumber(double: order!.subtotal()))
            case 1:
                cell = tableView.dequeueReusableCellWithIdentifier("TaxCell", forIndexPath: indexPath) as! UITableViewCell
                cell.detailTextLabel?.text = numberFormatter.stringFromNumber(NSNumber(double: order!.tax()))
            case 2:
                cell = tableView.dequeueReusableCellWithIdentifier("TotalCell", forIndexPath: indexPath) as! UITableViewCell
                cell.detailTextLabel?.text = numberFormatter.stringFromNumber(NSNumber(double: order!.total()))
            default:
                cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
                println("Also does not happen")
            }
        default:
            cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
            println("This doesn't happen")
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? objects!.count : 3
    }
    
}
