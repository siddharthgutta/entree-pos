
import UIKit

class CardPaymentViewController: UITableViewController, CFTReaderDelegate {
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Only delete the order if the party is not nil
        if let _ = order.party {
            for orderItem in order.orderItems {
                orderItem.order = nil
            }
            
            PFObject.saveAllInBackground(order.orderItems)
            
            order.deleteInBackgroundWithBlock {
                (succeeded, error) in
                if succeeded {
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
                }
            }
        } else {
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        completionHandler()
    }
    
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var orderTableViewCell: UITableViewCell!
    @IBOutlet weak var subtotalTableViewCell: UITableViewCell!
    @IBOutlet weak var cardReaderStatusTableViewCell: UITableViewCell!
    @IBOutlet weak var manualEntryTableViewCell: UITableViewCell!
    @IBOutlet weak var printReceiptTableViewCell: UITableViewCell!

    var currencyNumberFormatter: NSNumberFormatter {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        return formatter
    }
    
    var cardAuthorizedAlertController: UIAlertController {
        let alertController = UIAlertController(title: "Card Authorized",
            message: "At this time, no charge has been made. You may charge the card on the order overview panel.",
            preferredStyle: .Alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .Default) {
            (action) in
            
            self.configureViewWithCardAuthorized(true)
        }
        alertController.addAction(okayAction)

        return alertController
    }
    
    var order: Order!
    let reader = CFTReader(reader: 0)
    
    var completionHandler: (() -> Void)!
    
    // MARK: - CardPaymentViewController
    
    private func authorizeCard(card: CFTCard) {
        let authorizeDictionary = [
            "amount": NSDecimalNumber(double: order.subtotal)
        ]
        
        let success: (CFTCharge!) -> () = {
            (charge) in
            
            let payment = Payment()
            payment.restaurant = Restaurant.defaultRestaurantFromLocalDatastoreFetchIfNil()!
            payment.type = "Card"
            
            payment.cardFlightChargeToken = charge.token
            payment.cardLastFour = card.last4
            payment.cardName = card.name
            
            self.order.payment = payment
            payment.order = self.order
            
            PFObject.saveAllInBackground([payment, self.order]) {
                (succeeded, error) in
                
                if succeeded {
                    self.presentViewController(self.cardAuthorizedAlertController, animated: true, completion: nil)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(LOAD_OBJECTS_NOTIFICATION, object: nil)
                } else {
                    self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
                }
            }
        }
        
        let failure: (NSError!) -> () = {
            (error) in
            
            self.presentViewController(UIAlertController.alertControllerForError(error), animated: true, completion: nil)
        }
        
        card.authorizeCardWithParameters(authorizeDictionary, success: success, failure: failure)
    }
    
    private func beginManualEntry() {
        /*
        let paymentView = CFTPaymentView(frame: CGRect(x: 15, y: 150, width: 290, height: 45))
        paymentView.delegate = self
        paymentView.useFont(UIFont.systemFontOfSize(18))
        paymentView.useKeyboardAppearance(.Dark)
        
        self.paymentView = [[CFTPaymentView alloc] initWithFrame:CGRectMake(15, 150, 290, 45)];
        [self.paymentView setDelegate:self];
        [self.paymentView useFont:[UIFont fontWithName:kDefaultFont size:17]];
        [self.paymentView useFontColor:[UIColor blueColor]];
        [self.paymentView useKeyboardAppearance:UIKeyboardAppearanceDark];
        [self.view addSubview:self.paymentView];
        */
    }
    
    private func configureViewWithCardAuthorized(authorized: Bool) {
        orderTableViewCell.detailTextLabel?.text = order.objectId!
        subtotalTableViewCell.detailTextLabel?.text = currencyNumberFormatter.stringFromDouble(order.subtotal)
        
        cancelBarButtonItem.enabled = !authorized
        doneBarButtonItem.enabled = authorized
        
        manualEntryTableViewCell.selectionStyle = authorized ? .None : .Default
        manualEntryTableViewCell.textLabel?.textColor = authorized ? UIColor.grayColor() : UIColor.entreeBlueColor()
        printReceiptTableViewCell.selectionStyle = authorized ? .Default : .None
        printReceiptTableViewCell.textLabel?.textColor = authorized ? UIColor.entreeBlueColor() : UIColor.grayColor()
    }
    
    private func updateCardReaderStatusLabelWithMessage(message: String, textColor: UIColor) {
        cardReaderStatusTableViewCell.textLabel?.text = message
        cardReaderStatusTableViewCell.textLabel?.textColor = textColor
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reader.delegate = self
        reader.swipeHasTimeout(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureViewWithCardAuthorized(false)
    }
    
    // MARK: - CFTReaderDelegate
    
    func transactionResult(charge: CFTCharge!, withError error: NSError!) {
        // This is a required method, but we don't need it in this context.
    }
    
    func readerBatteryLow() {
        updateCardReaderStatusLabelWithMessage("Reader battery low", textColor: UIColor.redColor())
    }
    
    func readerCardResponse(card: CFTCard!, withError error: NSError!) {
        // TODO: The style of error checking here can probably be improved with the changes in Swift 2
        
        if let card = card {
            let authorizeCardAlertController = UIAlertController(title: "Authorize Card?", message: nil, preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            authorizeCardAlertController.addAction(cancelAction)
            
            let authorizeAction = UIAlertAction(title: "Authorize", style: .Default) {
                (action) in
                
                self.authorizeCard(card)
            }
            authorizeCardAlertController.addAction(authorizeAction)
            
            presentViewController(authorizeCardAlertController, animated: true, completion: nil)
        } else {
            presentViewController(UIAlertController.alertControllerForError(error), animated: true, completion: nil)
        }
    }
    
    func readerIsAttached() {
        updateCardReaderStatusLabelWithMessage("Reader detected...", textColor: UIColor.yellowColor())
    }
    
    func readerIsConnected(isConnected: Bool, withError error: NSError!) {
        if isConnected {
            reader.beginSwipe()
            
            updateCardReaderStatusLabelWithMessage("Reader is connected. Ready for swipe!", textColor: UIColor.greenColor())
        } else {
            presentViewController(UIAlertController.alertControllerForError(error), animated: true, completion: nil)
        }
    }
    
    func readerIsConnecting() {
        updateCardReaderStatusLabelWithMessage("Reader is connecting...", textColor: UIColor.yellowColor())
    }
    
    func readerIsDisconnected() {
        updateCardReaderStatusLabelWithMessage("Reader is disconnected.", textColor: UIColor.redColor())
    }
    
    func readerNotDetected() {
        updateCardReaderStatusLabelWithMessage("Reader not detected.", textColor: UIColor.redColor())
    }
    
    func readerSwipeDetected() {
        updateCardReaderStatusLabelWithMessage("Swipe detected...", textColor: UIColor.yellowColor())
    }
    
    func readerSwipeDidCancel() {
        updateCardReaderStatusLabelWithMessage("Swipe cancelled.", textColor: UIColor.redColor())
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath == NSIndexPath(forRow: 1, inSection: 1) {
            beginManualEntry()
        } else if indexPath == NSIndexPath(forRow: 0, inSection: 2) {
            PrintingManager.sharedManager().printReceiptForOrder(order, fromViewController: self)
            
            let receiptSentAlertController = UIAlertController(title: "Receipt Sent!", message: "The receipt has been sent to the printer.", preferredStyle: .Alert)
            
            let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            receiptSentAlertController.addAction(okayAction)
            
            presentViewController(receiptSentAlertController, animated: true, completion: nil)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
