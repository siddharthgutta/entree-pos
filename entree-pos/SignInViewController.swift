
import UIKit

class SignInViewController: UIViewController {

    @IBAction func signIn() {
        let alertController = UIAlertController(title: "Sign In", message: nil, preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.placeholder = "Email"
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAlertAction)
        
        let signInAlertAction = UIAlertAction(title: "Sign In", style: .Default) { (action: UIAlertAction!) in
            let textFields = alertController.textFields! as! [UITextField]
            
            let email = textFields.first!.text
            let password = textFields.last!.text
            
            PFUser.logInWithUsernameInBackground(email, password: password) { (user: PFUser?, error: NSError?) in
                if let user = user {
                    self.performSegueWithIdentifier("SelectRestaurant", sender: nil)
                } else {
                    println(error)
                }
            }
        }
        alertController.addAction(signInAlertAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}
