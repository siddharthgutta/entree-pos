
import UIKit

class EmployeeClockViewController: UIViewController {

    var employee: Employee!
    
    @IBAction func clockOut(sender: UIButton) {
        let shift = employee.currentShift!
        shift.endedAt = NSDate()
        shift.saveEventually(nil)
        
        employee.currentShift = nil
        employee.saveEventually(nil)
        
        switchServers(sender)
    }
    
    @IBAction func switchServers(sender: UIButton) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet var naturalLanguageTimerLabel: UILabel!
    @IBOutlet var timerLabel: UILabel!

    var timer: NSTimer?
    
    // MARK: - MeViewController
    
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
