
import UIKit

class SignInViewController: UIViewController {

    @IBAction func signIn() {
        let alertController = UIAlertController(title: "Login", message: nil, preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.keyboardType = .EmailAddress
            textField.placeholder = "Email"
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAlertAction)
        
        let signInAlertAction = UIAlertAction(title: "Login", style: .Default) { (action: UIAlertAction!) in
            let textFields = alertController.textFields! 
            
            let email = textFields.first!.text
            let password = textFields.last!.text
            
            PFUser.logInWithUsernameInBackground(email!, password: password!) { (user: PFUser?, error: NSError?) in
                if let _ = user {
                    self.performSegueWithIdentifier("SelectRestaurant", sender: nil)
                } else {
                    self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
                }
            }
        }
        alertController.addAction(signInAlertAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}
