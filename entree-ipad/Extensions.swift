
import UIKit

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
    
    static func entreeColorForIndex(index: Int) -> UIColor {
        switch index {
        case 0:
            return UIColor.redColor()
        case 1:
            return UIColor.orangeColor()
        case 2:
            return UIColor.yellowColor()
        case 3:
            return UIColor.greenColor()
        case 4:
            return UIColor.blueColor()
        case 5:
            return UIColor.purpleColor()
        default:
            return UIColor.blackColor()
        }
    }
    
}
