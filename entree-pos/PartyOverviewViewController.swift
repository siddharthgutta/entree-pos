
import UIKit

class PartyOverviewViewController: PFQueryTableViewController {
    
    var party: Party?
    
    // MARK: - PartyOverviewViewController
    
    private func paymentAtIndexPath(indexPath: NSIndexPath) -> Payment? {
        return objectAtIndexPath(indexPath) as? Payment
    }
    
    // MARK: - PFQueryTableViewController
    
    override func queryForTable() -> PFQuery {
        let query = Payment.query()!
        query.cachePolicy = .CacheThenNetwork
        query.limit = 1000
        
        query.whereKey("party", equalTo: party!)
        
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PFTableViewCell
        
        let payment = object as! Payment
        
        switch payment.type {
        case "Card":
            cell.textLabel?.text = "Card: \(payment.cardName) - \(payment.cardLastFour)"
        case "Cash":
            cell.textLabel?.text = "Cash Payment"
            cell.detailTextLabel?.text = "Paid"
        default:
            println("Unrecognized payment type")
        }
        
        return cell
    }
    
}
