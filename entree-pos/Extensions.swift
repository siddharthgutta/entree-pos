
import UIKit

extension NSCalendar {
    
    func endOfDayForDate(date: NSDate) -> NSDate {
        return NSCalendar.currentCalendar().startOfDayForDate(date.dateByAddingTimeInterval(86400))
    }
    
}

extension NSNumberFormatter {
    
    func stringFromDouble(double: Double) -> String? {
        return stringFromNumber(NSNumber(double: double))
    }
    
}

extension PFObject {
    
    func hasSameObjectIDAs(object: PFObject) -> Bool {
        return self.objectId! == object.objectId!
    }
    
}

extension String {
    
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
    
    var intValue: Int {
        return (self as NSString).integerValue
    }
    
}

extension UIAlertController {
    
    static func alertControllerForError(error: NSError) -> UIAlertController {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
        return alertController
    }
    
}

extension UIColor {
    
    static func entreeBlueColor() -> UIColor {
        return UIColor(red:0.15, green:0.39, blue:0.85, alpha:1)
    }
    
    static func entreeGreenColor() -> UIColor {
        return UIColor(red:0.14, green:0.73, blue:0.11, alpha:1)
    }
    
    static func entreeRedColor() -> UIColor {
        return UIColor(red:0.99, green:0.23, blue:0.25, alpha:1)
    }
    
}

extension UIImage {
    
    func tintedGradientImageWithColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        tintColor.setFill()
        
        let bounds = CGRectMake(0, 0, size.width, size.height)
        UIRectFill(bounds)
        
        drawInRect(bounds, blendMode: .Overlay, alpha: 1)
        drawInRect(bounds, blendMode: .DestinationIn, alpha: 1)

        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage
    }
    
}
