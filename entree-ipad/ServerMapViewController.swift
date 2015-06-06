
import UIKit

class ServerMapViewController: UIViewController {
    
    var employee: Employee!
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "EmployeeClock":
            if let employeeClockViewController = segue.destinationViewController as? EmployeeClockViewController {
                employeeClockViewController.employee = employee
            }
        default:
            fatalError(UNRECOGNIZED_SEGUE_IDENTIFIER_ERROR_MESSAGE)
        }
    }
    
}
