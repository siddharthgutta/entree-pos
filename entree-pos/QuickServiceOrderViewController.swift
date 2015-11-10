
import UIKit

class QuickServiceOrderViewController: PFQueryTableViewController {
    
    @IBAction func pay(sender: UIBarButtonItem) {
        let paymentTypeAlertController = UIAlertController(title: "Payment Type", message: nil, preferredStyle: .ActionSheet)
        
        let cardAction = UIAlertAction(title: "Card", style: .Default) {
            (action) in
            let navController = UIStoryboard(name: "CardPayment", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! UINavigationController
            let cardPaymentViewController = navController.viewControllers.first as! CardPaymentViewController
            cardPaymentViewController.order = self.order
            cardPaymentViewController.completionHandler = {
                self.dismissViewControllerAnimated(true) {
                    () in
                    self.sendToKitchen()
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName(LOAD_OBJECTS_NOTIFICATION, object: nil)
                }
            }
            
            navController.modalPresentationStyle = .FormSheet
            self.presentViewController(navController, animated: true, completion: nil)
        }
        paymentTypeAlertController.addAction(cardAction)
        
        let cashAction = UIAlertAction(title: "Cash", style: .Default) {
            (action) in
            let navController = UIStoryboard(name: "CashPayment", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! UINavigationController
            let cashPaymentViewController = navController.viewControllers.first as! CashPaymentViewController
            cashPaymentViewController.order = self.order
            cashPaymentViewController.completionHandler = {
                self.dismissViewControllerAnimated(true) {
                    () in
                    self.sendToKitchen()
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName(LOAD_OBJECTS_NOTIFICATION, object: nil)
                }
            }
            
            navController.modalPresentationStyle = .FormSheet
            self.presentViewController(navController, animated: true, completion: nil)
        }
        paymentTypeAlertController.addAction(cashAction)
        
        presentViewController(paymentTypeAlertController, animated: true, completion: nil)
        
        paymentTypeAlertController.popoverPresentationController?.barButtonItem = sender
    }
    
    @IBOutlet weak var itemsCountLabel: UILabel!
    @IBOutlet weak var amountDueLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    
    var order: Order!
    
    var currencyFormatter: NSNumberFormatter {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        return formatter
    }
    
    // MARK: - QuickServiceOrderViewController
    
    func cancel(sender: UIBarButtonItem) {
        let objectsToDelete: [PFObject] = [order] + order.orderItems
        PFObject.deleteAllInBackground(objectsToDelete) { successful, error in
            if successful {
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
            }
        }
    }
    
    private func configureFooterView() {
        order.crunchTheNumbers()
        
        itemsCountLabel.text = "\(order.orderItems.count) Items"
        amountDueLabel.text = "Amount Due: " + currencyFormatter.stringFromDouble(order.amountDue)!
        taxLabel.text = "Tax: " + currencyFormatter.stringFromDouble(order.tax)!
        subtotalLabel.text = "Subtotal: " + currencyFormatter.stringFromDouble(order.subtotal)!
    }
    
    func dismiss(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendToKitchen() {
        PrintingManager.sharedManager().printPrintJobsForOrderItems(objects as! [OrderItem], party: nil, server: order.server, toGo: false, fromViewController: self)
        
        for orderItem in objects as! [OrderItem] {
            orderItem.sentToKitchen = true
        }
        
        PFObject.saveAllInBackground(objects as? [PFObject]) { successful, error in
            self.loadObjects()
        }
    }
    
    // MARK: - PFQueryTableViewController
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        configureFooterView()
    }
    
    override func queryForTable() -> PFQuery {
        let query = OrderItem.query()!
        
        query.includeKey("menuItem")
        query.includeKey("menuItem.menuCategory")
        query.includeKey("menuItem.menuCategory.menu")
        query.includeKey("menuItem.printJobs")
        query.includeKey("menuItem.printJobs.printer")
        query.includeKey("menuItemModifiers")
        
        query.whereKey("order", equalTo: order)
        
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("OrderItemCell", forIndexPath: indexPath) as! PFTableViewCell
        
        let orderItem = object as! OrderItem
        
        cell.textLabel?.text = orderItem.menuItem.name
        cell.detailTextLabel?.text = orderItem.notes
        
        if orderItem.sentToKitchen {
            cell.imageView?.image = UIImage(named: "Paper Airplane")
        }
        
        return cell
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadObjects", name: LOAD_OBJECTS_NOTIFICATION, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if order.type == "Quick Service" {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel:")
        } else if order.type == "Customer Tab" {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "dismiss:")
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let orderItemToDelete = objectAtIndexPath(indexPath) as! OrderItem
            
            var index = 0
            for orderItem in order.orderItems {
                if orderItem.objectId! == orderItemToDelete.objectId! {
                    order.orderItems.removeAtIndex(index)
                }
                index++
            }
            
            try! order.save()
            
            removeObjectAtIndexPath(indexPath)
            
            configureFooterView()
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let navController = UIStoryboard(name: "OrderItemDetail", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! UINavigationController
        let quickServiceOrderItemDetailViewController = navController.viewControllers.first as! QuickServiceOrderItemDetailViewController
        quickServiceOrderItemDetailViewController.orderItem = objectAtIndexPath(indexPath) as! OrderItem
        
        navController.modalPresentationStyle = .FormSheet
        presentViewController(navController, animated: true, completion: nil)
    }
    
}