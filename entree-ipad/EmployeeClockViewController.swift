
import UIKit

class EmployeeClockViewController: UIViewController {

    @IBAction func clockOut(sender: UIButton) {
        let shift = employee.currentShift!
        shift.endedAt = NSDate()
        
        employee.currentShift = nil
        
        PFObject.saveAllInBackground([shift, employee]) { (succeeded: Bool, error: NSError?) in
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

    var employee: Employee!
    var timer: NSTimer?
    
    // MARK: - EmployeeClockViewController
    
    func updateView() {
        let startedAt = employee.currentShift!.startedAt
        
        let unitFlags = NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay
        let components = NSCalendar.currentCalendar().components(unitFlags, fromDate: startedAt, toDate: NSDate(), options: nil)
        
        let dateComponentsFormatter = NSDateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = .Full
        
        naturalLanguageTimerLabel.text = "You have been clocked-in for " + dateComponentsFormatter.stringFromDateComponents(components)!
        
        dateComponentsFormatter.unitsStyle = .Positional
        timerLabel.text = dateComponentsFormatter.stringFromDateComponents(components)!
    }
    
    // MARK: - UIViewController
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        timer = NSTimer(timeInterval: 1, target: self, selector: Selector("updateView"), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        
        timer = nil
    }
    
}
