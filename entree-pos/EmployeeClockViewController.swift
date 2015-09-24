
import UIKit

class EmployeeClockViewController: UITableViewController {
    
    @IBOutlet weak var currentShiftTimerLabel: UILabel!

    var employee: Employee?
    var timer: NSTimer?

    let dateComponentsFormatter = NSDateComponentsFormatter()
    
    var switchServersTableViewCellIndexPath = NSIndexPath(forRow: 0, inSection: 1)
    var clockOutTableViewCellIndexPath = NSIndexPath(forRow: 1, inSection: 1)
    
    required init!(coder aDecoder: NSCoder) {
        
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - EmployeeClockViewController
    
    private func clockOut() {
        if let currentShift = employee?.currentShift {
            currentShift.endedAt = NSDate()
            
            employee?.currentShift = nil
            
            PFObject.saveAllInBackground([currentShift, employee!]) { (succeeded: Bool, error: NSError?) in
                if succeeded {
                    self.switchServers()
                } else {
                    print(error)
                }
            }
        }
    }
    
    private func switchServers() {
        presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateTimerLabel() {
        if let currentShift = employee?.currentShift {
            let timeInterval = NSDate().timeIntervalSinceDate(currentShift.startedAt)
            
            
            dateComponentsFormatter.unitsStyle = .Abbreviated
            
            currentShiftTimerLabel.text = dateComponentsFormatter.stringFromTimeInterval(timeInterval)
        }
    }
    
    // MARK: - UIViewController
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        updateTimerLabel()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTimerLabel"), userInfo: nil, repeats: true)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            switchServers()
        } else if indexPath.row == 1 {
            clockOut()
        }
    }
    
}
