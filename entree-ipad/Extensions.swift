
import UIKit

extension NSCalendar {
    
    func endOfDayForDate(date: NSDate) -> NSDate {
        let nextDay = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: 1, toDate: date, options: nil)!
        return NSCalendar.currentCalendar().startOfDayForDate(nextDay)
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
        
        drawInRect(bounds, blendMode: kCGBlendModeOverlay, alpha: 1)
        drawInRect(bounds, blendMode: kCGBlendModeDestinationIn, alpha: 1)

        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage
    }
    
}

extension PFObject {
    
    func same(object: PFObject) -> Bool {
        return self.objectId! == object.objectId!
    }
    
}

