
import UIKit

class TicketHeaderView: UIView {

    let textLabel: UILabel
    let detailLabel: UILabel
    let printButton: UIButton
    let payButton: UIButton
    
    override init(frame: CGRect) {
        textLabel = UILabel()
        textLabel.font = UIFont(name: "Menlo", size: 14)
        textLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        detailLabel = UILabel()
        detailLabel.font = UIFont(name: "Menlo", size: 14)
        detailLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        printButton = UIButton.buttonWithType(.System) as! UIButton
        printButton.titleLabel!.font = UIFont(name: "Menlo", size: 14)
        printButton.tintColor = UIColor.entreeBlueColor()
        printButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        payButton = UIButton.buttonWithType(.System) as! UIButton
        payButton.titleLabel!.font = UIFont(name: "Menlo", size: 14)
        payButton.tintColor = UIColor.entreeGreenColor()
        payButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        super.init(frame: frame)
        
        addSubview(textLabel)
        addSubview(detailLabel)
        addSubview(printButton)
        addSubview(payButton)
        
        addConstraint(NSLayoutConstraint(item: textLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: textLabel, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 16))
        
        addConstraint(NSLayoutConstraint(item: detailLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: detailLabel, attribute: .Right, relatedBy: .Equal, toItem: printButton, attribute: .Right, multiplier: 1, constant: -8))
        
        addConstraint(NSLayoutConstraint(item: printButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: printButton, attribute: .Right, relatedBy: .Equal, toItem: payButton, attribute: .Right, multiplier: 1, constant: -8))
        
        addConstraint(NSLayoutConstraint(item: payButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: payButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -16))
    }

    required convenience init(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }

}
