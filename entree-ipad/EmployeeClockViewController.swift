
import UIKit

class EmployeeClockViewController: UIViewController {

    @IBAction func clockOut(sender: UIButton) {
        let shift = employee!.currentShift!
        shift.endedAt = NSDate()
        
        employee!.currentShift = nil
        
        PFObject.saveAllInBackground([shift, employee!]) { (succeeded: Bool, error: NSError?) in
            if succeeded {
                self.switchServers(sender)
            } else {
                fatalError(error!.localizedDescription)
            }
        }
    }
    
    @IBAction func switchServers(sender: UIButton) {
        presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
        presentingViewController!.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet var naturalLanguageTimerLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!

    var employee: Employee?
    var timer: NSTimer?
    
    // MARK: - EmployeeClockViewController
    
    func update() {
        if let shift = employee?.currentShift {
            let timeInterval = NSDate().timeIntervalSinceDate(shift.startedAt)
            
            let dateComponentsFormatter = NSDateComponentsFormatter()
            dateComponentsFormatter.unitsStyle = .Full
            
            naturalLanguageTimerLabel.text = "You have been clocked-in for " + dateComponentsFormatter.stringFromTimeInterval(timeInterval)!
            
            dateComponentsFormatter.unitsStyle = .Positional
            
            timerLabel.text = dateComponentsFormatter.stringFromTimeInterval(timeInterval)!
        }
    }
    
    // MARK: - UIViewController
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        update()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer = nil
    }
    
}
