
import UIKit

class BadgeLabel: UILabel {

    @IBInspectable var badgeColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.backgroundColor = badgeColor.CGColor
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.cornerRadius = 4
        
        textAlignment = .Center
        textColor = UIColor.whiteColor()
    }
    
    override func intrinsicContentSize() -> CGSize {
        let originalSize = super.intrinsicContentSize()
        let width: CGFloat = originalSize.width + 16.0
        return CGSizeMake(width, originalSize.height)
    }
    
}
