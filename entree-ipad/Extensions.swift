
import UIKit

extension UIColor {
    
    convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = advance(rgba.startIndex, 1)
            let hex     = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                switch (count(hex)) {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
                }
            } else {
                println("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
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
            return UIColor(rgba: "#00C1D7") // Light Blue
        case 1:
            return UIColor(rgba: "#FF9100") // Orange
        case 2:
            return UIColor(rgba: "#00B950") // Green
        case 3:
            return UIColor(rgba: "#7E5245") // Brown
        case 4:
            return UIColor(rgba: "#1479DE") // Blue
        case 5:
            return UIColor(rgba: "#5A7E8C") // Gray
        case 6:
            return UIColor(rgba: "#FFC200") // Yellow
        case 7:
            return UIColor(rgba: "#4842B8") // Purple
        case 8:
            return UIColor(rgba: "#009C8A") // Teal
        case 9:
            return UIColor(rgba: "#EF4836") // Red
        default:
            return UIColor.blackColor() // Default to black (Just in case)
        }
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

