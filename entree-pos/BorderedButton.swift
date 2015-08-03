
import UIKit

@IBDesignable class BorderedButton: UIButton {
    
    @IBInspectable var borderColor: UIColor {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        borderColor = UIColor.clearColor()
        
        super.init(coder: aDecoder)
        
        layer.borderWidth = 1
        layer.cornerRadius = 4
    }
    
    override func intrinsicContentSize() -> CGSize {
        var originalSize = super.intrinsicContentSize()
        originalSize.width = originalSize.width + 16
        return originalSize
    }
    
}
