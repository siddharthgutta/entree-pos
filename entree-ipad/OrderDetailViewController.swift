
import UIKit

class OrderDetailViewController: UITableViewController {

    @IBAction func dismiss(sender: UIBarButtonItem) {
        order.deleteInBackgroundWithBlock { (succeeded: Bool, error: NSError?) in
            if succeeded {
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                println(error?.localizedDescription)
            }
        }
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
        order.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) in
            if succeeded {
                NSNotificationCenter.defaultCenter().postNotificationName(LOAD_OBJECTS_NOTIFICATION, object: nil)
                
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                println(error?.localizedDescription)
            }
        }
    }
    
    var order: Order!
    
    // MARK: - OrderDetailViewController
    
    func updateSeatNumber(sender: UIStepper) {
        order.seat = Int(sender.value)
        
        tableView.reloadData()
    }
    
    // MARK: - UIViewController
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("MenuItemCell", forIndexPath: indexPath) as! UITableViewCell
                cell.textLabel!.text = order.menuItem.name
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("SeatNumberCell", forIndexPath: indexPath) as! UITableViewCell
                if let seatNumberLabel = cell.viewWithTag(100) as? UILabel {
                    seatNumberLabel.text = order.seat == 0 ? "Seat: None" : "Seat: \(order.seat)"
                }
                if let seatNumberStepper = cell.viewWithTag(200) as? UIStepper {
                    seatNumberStepper.value = Double(order.seat)
                    seatNumberStepper.addTarget(self, action: Selector("updateSeatNumber:"), forControlEvents: .ValueChanged)
                }
            }
        case 1:
            if indexPath.row == order.menuItemModifiers.count {
                cell = tableView.dequeueReusableCellWithIdentifier("AddModifierCell", forIndexPath: indexPath) as! UITableViewCell
                cell.textLabel!.text = "Add Modifier"
                cell.textLabel!.textColor = UIColor.entreeBlueColor()
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("MenuItemModifierCell", forIndexPath: indexPath) as! UITableViewCell
                cell.textLabel!.text = order.menuItemModifiers[indexPath.row].name
            }
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("NotesCell", forIndexPath: indexPath) as! UITableViewCell
            if let notesTextView = cell.viewWithTag(100) as? UITextView {
                notesTextView.text = order.notes
            }
        default:
            cell = UITableViewCell()
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return order.menuItemModifiers.count + 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 2 ? 200 : 50
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return "MODIFIERS"
        case 2:
            return "NOTES"
        default:
            return nil
        }
    }
    
}
