
import UIKit

class CardPaymentViewController: UITableViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let alertController = UIAlertController(title: "Payment Disabled", message: "Payment has been disabled in this demo for security purposes.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /*
    
    @IBOutlet var authorizeChargeTableViewCell: UITableViewCell!
    @IBOutlet var cardReaderStatusTableViewCell: UITableViewCell!
    
    @IBAction func authorizeCharge(sender: UIButton) {
    
    }

    var enableAuthorizeChargeTableViewCell: Bool = false
    var payment: Payment?
    var reader = CFTReader(reader: 0)
    
    // MARK: - CardPaymentViewController
    
    private func updateCardReaderStatusLabelWithMessage(message: String, textColor: UIColor) {
        cardReaderStatusTableViewCell.textLabel?.text = message
        cardReaderStatusTableViewCell.textLabel?.textColor = textColor
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
        
    }
    
    func readerIsAttached() {
        updateCardReaderStatusLabelWithMessage("Reader detected...", textColor: UIColor.yellowColor())
    }
    
    func readerIsConnected(isConnected: Bool, withError error: NSError!) {
        if isConnected {
            updateCardReaderStatusLabelWithMessage("Reader is connected. Ready for swipe", textColor: UIColor.greenColor())
        } else {
            println("Reader didn't connect with error: \(error.localizedDescription)")
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

*/
    
}
