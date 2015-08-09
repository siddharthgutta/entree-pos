
import UIKit

class OrderViewController: PFQueryTableViewController {
    
    @IBAction func cancel() {
        for orderItem in order.orderItems {
            orderItem.order = nil
        }
        
        PFObject.saveAll(order.orderItems)
        
        order.deleteInBackgroundWithBlock { (success: Bool, error: NSError?) in
            if success {
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBAction func next() {
        let alertController = UIAlertController(title: "Payment Type", message: nil, preferredStyle: .Alert)
        
        let cashAction = UIAlertAction(title: "Cash", style: .Default) { (action: UIAlertAction!) in
            self.performSegueWithIdentifier("Cash", sender: nil)
        }
        alertController.addAction(cashAction)
        
        let cardAction = UIAlertAction(title: "Card", style: .Default) { (action: UIAlertAction!) in
            self.performSegueWithIdentifier("Card", sender: nil)
        }
        alertController.addAction(cardAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    var order: Order!

    let numberFormatter = NSNumberFormatter.numberFormatterWithStyle(.CurrencyStyle)
    
    // MARK: - PFQueryTableViewController
    
    override func queryForTable() -> PFQuery {
        let query = OrderItem.query()!
        query.limit = 1000
        
        query.includeKey("menuItem")
        
        query.orderByAscending("createdAt")
        
        query.whereKey("order", equalTo: order)
        
        return query
    }
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segue.destinationViewController.setValue(order, forKey: "order")
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
