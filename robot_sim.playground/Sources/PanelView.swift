import Foundation
import SceneKit
import UIKit

public class ColoredStackView: UIStackView {

    var color: UIColor?

    var topInset: CGFloat = 0.0
    var bottomInset: CGFloat = 0.0
    var leftInset: CGFloat = 0.0
    var rightInset: CGFloat = 0.0

    var cornerRadius: CGFloat = 0.0
    var borderColor: UIColor = .clear
    
    public override var backgroundColor: UIColor? {
        get { return color }
        set {
            color = newValue
            self.setNeedsLayout()
        }
    }

    private lazy var backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        self.layer.insertSublayer(layer, at: 0)
        return layer
    }()

    public override func layoutSubviews() {
        super.layoutSubviews()

        backgroundLayer.path = UIBezierPath(roundedRect:
            CGRect(x: leftInset,
                   y: topInset,
                   width: self.bounds.width - leftInset - rightInset,
                   height: self.bounds.height - topInset - bottomInset),
                                            cornerRadius: cornerRadius).cgPath
        backgroundLayer.strokeColor = self.borderColor.cgColor
        backgroundLayer.lineWidth = 1
        backgroundLayer.fillColor = self.backgroundColor?.cgColor
    }
}

public class PanelView: ColoredStackView {
    
    lazy var addButton: IndustrialButtonView = {
        return IndustrialButtonView(.green, text: "ADD")
    }()
    
    lazy var popButton: IndustrialButtonView = {
        return IndustrialButtonView(.red, text: "POP")
    }()
    
    lazy var clearButton: IndustrialButtonView = {
        return IndustrialButtonView(.red, text: "CLEAR")
    }()
    
    lazy var playButton: IndustrialButtonView = {
        return IndustrialButtonView(.green, text: "PLAY")
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        
        let leftActionView = ColoredStackView(arrangedSubviews: [playButton])

        leftActionView.cornerRadius = 8
        leftActionView.borderColor = .white
        leftActionView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        leftActionView.isLayoutMarginsRelativeArrangement = true

        let rightActionView = ColoredStackView(arrangedSubviews: [addButton, popButton, clearButton])

        rightActionView.cornerRadius = 8
        rightActionView.borderColor = .white

        rightActionView.alignment = .center
        rightActionView.axis = .horizontal
        rightActionView.distribution = .fillEqually
        rightActionView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        rightActionView.isLayoutMarginsRelativeArrangement = true
        rightActionView.spacing = 12
        
        
        
        let wrapperStackView = UIStackView(arrangedSubviews: [leftActionView, rightActionView])
        wrapperStackView.alignment = .center
        wrapperStackView.axis = .horizontal
        wrapperStackView.distribution = .fillProportionally
        wrapperStackView.spacing = 16
        
        
        self.addArrangedSubview(wrapperStackView)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.isLayoutMarginsRelativeArrangement = true
        self.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        self.cornerRadius = 8
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
