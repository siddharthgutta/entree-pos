
import UIKit

class QuickServiceOrderItemDetailViewController: UITableViewController {
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        if let order = orderItem?.order {
            var index = 0
            for item in order.orderItems {
                if orderItem.objectId == item.objectId {
                    order.orderItems.removeAtIndex(index)
                }
                index++
            }
            
            do {
                let _ = try order.save() // Probably improper use of throws on Parse's part
            } catch {
                print("Error saving order: \(error)")
            }
        }

        orderItem.deleteInBackground()
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        
        NSNotificationCenter.defaultCenter().postNotificationName(LOAD_OBJECTS_NOTIFICATION, object: nil)
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
        orderItem.seatNumber = Int(seatNumberStepper.value)
        orderItem.onTheHouse = onTheHouseSwitch.on
        
        orderItem.notes = notesTextView.text
        
        orderItem.saveInBackgroundWithBlock {
            (succeeded, error) in
            if succeeded {
                self.presentingViewController?.dismissViewControllerAnimated(true) {
                    () in
                    NSNotificationCenter.defaultCenter().postNotificationName(LOAD_OBJECTS_NOTIFICATION, object: nil)
                }
            } else {
                self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
            }
        }
    }
    
    @IBOutlet weak var menuItemNameLabel: UILabel!
    @IBOutlet weak var seatNumberLabel: UILabel!
    @IBOutlet weak var seatNumberStepper: UIStepper!
    @IBOutlet weak var onTheHouseSwitch: UISwitch!
    @IBOutlet weak var menuItemModifiersLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    
    var orderItem: OrderItem!
    
    // MARK: - QuickServiceOrderItemDetailViewController
    
    private func configureView() {
        menuItemNameLabel.text = orderItem.menuItem.name
        seatNumberLabel.text = "Seat: \(orderItem.seatNumber)"
        seatNumberStepper.value = Double(orderItem.seatNumber)
        onTheHouseSwitch.on = orderItem.onTheHouse
        
        let modifiersText = orderItem.menuItemModifiers.reduce("") {
            (previous, modifier) in
            return "\(previous)\(modifier.name); "
        }
        menuItemModifiersLabel.text = modifiersText.isEmpty ? "None" : modifiersText
        
        notesTextView.text = orderItem.notes
    }
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Modifiers" {
            let quickServiceMenuItemModifierSelectionViewController = segue.destinationViewController as! QuickServiceMenuItemModifierSelectionViewController
            quickServiceMenuItemModifierSelectionViewController.orderItem = orderItem
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    
}