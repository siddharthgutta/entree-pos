
import UIKit

class OrderItemDetailViewController: UITableViewController, UITextViewDelegate {

    @IBAction func dismiss(sender: UIBarButtonItem) {
        orderItem.deleteInBackgroundWithBlock { (succeeded: Bool, error: NSError?) in
            if succeeded {
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                println(error?.localizedDescription)
            }
        }
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
        orderItem.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) in
            if succeeded {
                NSNotificationCenter.defaultCenter().postNotificationName(LOAD_OBJECTS_NOTIFICATION, object: nil)
                
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                println(error?.localizedDescription)
            }
        }
    }
    
    let numberFormatter = NSNumberFormatter()
    var orderItem: OrderItem!
    
    // MARK: - OrderDetailViewController
    
    func reloadData() {
        var stash: String?
        
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2)),
        let notesTextView = cell.viewWithTag(100) as? UITextView {
            stash = notesTextView.text
        }
        
        tableView.reloadData()
        
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2)),
        let notesTextView = cell.viewWithTag(100) as? UITextView {
            notesTextView.text = stash
        }
    }
    
    func updateSeatNumber(sender: UIStepper) {
        orderItem.seatNumber = Int(sender.value)
        
        reloadData()
    }
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "MenuItemModifier":
            if let navigationController = segue.destinationViewController as? UINavigationController,
            let menuItemModifierListViewController = navigationController.viewControllers.first as? MenuItemModifierListViewController {
                menuItemModifierListViewController.orderItem = orderItem
            }
        default:
            fatalError(UNRECOGNIZED_SEGUE_IDENTIFIER_ERROR_MESSAGE)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberFormatter.numberStyle = .CurrencyStyle
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadData"), name: LOAD_OBJECTS_NOTIFICATION, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 1 && indexPath.row != orderItem.menuItemModifiers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("MenuItemCell", forIndexPath: indexPath) as! UITableViewCell
                cell.textLabel?.text = orderItem.menuItem.name
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("SeatNumberCell", forIndexPath: indexPath) as! UITableViewCell
                if let seatNumberLabel = cell.viewWithTag(100) as? UILabel {
                    seatNumberLabel.text = orderItem.seatNumber == 0 ? "Seat: None" : "Seat: \(orderItem.seatNumber)"
                }
                if let seatNumberStepper = cell.viewWithTag(200) as? UIStepper {
                    seatNumberStepper.value = Double(orderItem.seatNumber)
                    seatNumberStepper.addTarget(self, action: Selector("updateSeatNumber:"), forControlEvents: .ValueChanged)
                }
            }
        case 1:
            if indexPath.row == orderItem.menuItemModifiers.count {
                cell = tableView.dequeueReusableCellWithIdentifier("AddModifierCell", forIndexPath: indexPath) as! UITableViewCell
                cell.textLabel?.text = "Add Modifier"
                cell.textLabel?.textColor = UIColor.entreeBlueColor()
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("MenuItemModifierCell", forIndexPath: indexPath) as! UITableViewCell
                cell.textLabel?.text = orderItem.menuItemModifiers[indexPath.row].name
                cell.detailTextLabel?.text = numberFormatter.stringFromNumber(NSNumber(double: orderItem.menuItemModifiers[indexPath.row].price))
            }
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("NotesCell", forIndexPath: indexPath) as! UITableViewCell
            if let notesTextView = cell.viewWithTag(100) as? UITextView {
                notesTextView.text = orderItem.notes
                notesTextView.delegate = self
            }
        default:
            cell = UITableViewCell()
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            orderItem.menuItemModifiers.removeAtIndex(indexPath.row)
            
            orderItem.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) in
                if succeeded {
                    self.reloadData()
                } else {
                    println(error?.localizedDescription)
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return orderItem.menuItemModifiers.count + 1
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "Remove"
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "\(orderItem.menuItem.menuCategory.menu.name) – \(orderItem.menuItem.menuCategory.name)"
        case 1:
            return "MODIFIERS"
        case 2:
            return "NOTES"
        default:
            return nil
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == orderItem.menuItemModifiers.count {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            performSegueWithIdentifier("MenuItemModifier", sender: tableView.cellForRowAtIndexPath(indexPath))
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 2 ? 200 : 50
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(textView: UITextView) {
        orderItem.notes = textView.text
    }
    
}
