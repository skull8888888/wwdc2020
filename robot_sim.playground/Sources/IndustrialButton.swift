import Foundation
import SceneKit
import UIKit

public class IndustrialButton: UIButton {
    
    public enum IndustrialButtonType {
        case green
        case red
        
        var color: UIColor {
            switch self {
            case .green:
                return UIColor.green
            case .red:
                return UIColor.red
            }
        }
    }
    
    private let industrialType: IndustrialButtonType
    
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? self.industrialType.color : self.industrialType.color.withAlphaComponent(0.8)
        }
    }
    
    init(_ industrialType: IndustrialButton.IndustrialButtonType) {
        
        self.industrialType = industrialType

        super.init(frame: .zero)
        self.backgroundColor = self.industrialType.color.withAlphaComponent(0.8)
        
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = true
        
        let width: CGFloat = 30
        
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
        self.heightAnchor.constraint(equalToConstant: width).isActive = true
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = width / 2
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public class IndustrialButtonView: UIStackView {

    var button: IndustrialButton!
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 8)
        label.textAlignment = .center
        
        return label
    }()
    
    init(_ type: IndustrialButton.IndustrialButtonType, text: String) {
        super.init(frame: .zero)
        
        
        self.addArrangedSubview(label)
        label.text = text
        
        button = IndustrialButton(type)
        self.addArrangedSubview(button)
        
        self.spacing = 8
        
        self.alignment = .center
        self.axis = .vertical
        self.distribution = .fillProportionally
        self.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
