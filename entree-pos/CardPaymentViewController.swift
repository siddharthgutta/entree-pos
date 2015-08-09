
import UIKit

class CardPaymentViewController: UITableViewController, CFTReaderDelegate {
    
    @IBOutlet var amountDueTableViewCell: UITableViewCell!
    @IBOutlet var cardReaderStatusTableViewCell: UITableViewCell!

    let numberFormatter = NSNumberFormatter.numberFormatterWithStyle(.CurrencyStyle)
    var order: Order!
    var reader: CFTReader
    
    // MARK: - Init
    
    required init!(coder aDecoder: NSCoder!) {
        reader = CFTReader(reader: 0)
        
        super.init(coder: aDecoder)
        
        reader.delegate = self
    }
    
    // MARK: - CardPaymentViewController
    
    private func updateCardReaderStatusLabelWithMessage(message: String, textColor: UIColor) {
        cardReaderStatusTableViewCell.textLabel?.text = message
        cardReaderStatusTableViewCell.textLabel?.textColor = textColor
    }
    
    // MARK: - UIViewController
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        amountDueTableViewCell.detailTextLabel?.text = numberFormatter.stringFromNumber(NSNumber(double: order.total()))
    }
    
    // MARK: - CFTReaderDelegate
    
    func transactionResult(charge: CFTCharge!, withError error: NSError!) {
        if charge != nil {
            println(charge)
        } else {
            println(error.localizedDescription)
        }
    }
    
    func readerBatteryLow() {
        updateCardReaderStatusLabelWithMessage("Reader battery low", textColor: UIColor.redColor())
    }
    
    func readerCardResponse(card: CFTCard!, withError error: NSError!) {
        if let card = card {
            let authorizeDictionary = [
                "amount": 0.0 // Disabled for testing. Should normally be `NSDecimalNumber(double: order.total())`.
            ]
            
            card.authorizeCardWithParameters(authorizeDictionary, success: { (charge: CFTCharge!) in
                let payment = Payment()
                payment.type = "Card"
                
                payment.cardFlightChargeToken = charge.token
                payment.cardLastFour = card.last4
                payment.cardName = card.name
                
                payment.order = self.order
                
                self.order.payment = payment
                
                PFObject.saveAllInBackground([payment, self.order]) { (success: Bool, error: NSError?)  in
                    if success {
                        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(LOAD_OBJECTS_NOTIFICATION, object: nil)
                    } else {
                        // If this fails, we're kinda screwed...
                    }
                }
            }) { (error: NSError!) in
                self.presentViewController(UIAlertController.alertControllerForError(error), animated: true, completion: nil)
            }
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

}
