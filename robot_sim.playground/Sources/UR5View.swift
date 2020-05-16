import Foundation
import SceneKit


public class UR5View: SCNView {

    var lastPanLocation = SCNVector3()
    var panStartZ: CGFloat = 0

    var T06: Matrix4!
    
    var controlSphere: SCNNode!
    
    var ghostNode: SCNNode!
    
    var ur5: UR5!
    
    var isControlSphereSelected = false {
        
        didSet {
            if isControlSphereSelected {
                controlSphere.geometry?.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(120/255.0), green: CGFloat(155/255.0), blue: CGFloat(187/255.0), alpha: 1.0)
            } else {
                controlSphere.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            }
        }
        
    }
    
    var isAnimationPlaying = false
    
    lazy var addButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.frame.size = CGSize(width: 20, height: 20)
        button.setImage(UIImage(systemName: "search"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    var controlPoints: [[Scalar]] = []
    var controlNodes: [SCNNode] = []
    
    
    public override init(frame: CGRect, options: [String : Any]? = nil) {
        super.init(frame: frame, options: options)
        
    
        let scene = SCNScene(named: "base.scn")!
        
        ghostNode = SCNNode()
        scene.rootNode.addChildNode(ghostNode)
        
        controlSphere = SCNNode(geometry: SCNSphere(radius: 0.05))
        controlSphere.opacity = 0.4
        
        scene.rootNode.addChildNode(controlSphere)
            
        ur5 = UR5(scene: scene)
        self.scene = scene
        
        // move to initial position
        
        T06 = Matrix4(translation: Vector3(-0.4, 0, 0.4)) * Matrix4(rotation: Vector4(1,0,0,.pi))
        ur5.setJoints(ur5.IK(T06))
        
        
        controlSphere.position = SCNVector3(-T06.m41,T06.m43,T06.m42)
        
        self.backgroundColor = .white
       
        self.allowsCameraControl = true
        self.autoenablesDefaultLighting = true
        
        let panGR = UILongPressGestureRecognizer(target: self, action: #selector(handlePan(panGesture:)))
        self.addGestureRecognizer(panGR)
            
        let panelView = PanelView(frame: .zero)
        self.addSubview(panelView)
        
        panelView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        panelView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16).isActive = true
            
        panelView.playButton.button.addTarget(self, action: #selector(playButtonTapped(button:)), for: .touchUpInside)
        
        panelView.addButton.button.addTarget(self, action: #selector(addButtonTapped(button:)), for: .touchUpInside)
        panelView.popButton.button.addTarget(self, action: #selector(popButtonTapped(button:)), for: .touchUpInside)
        panelView.clearButton.button.addTarget(self, action: #selector(clearButtonTapped(button:)), for: .touchUpInside)
        
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func clearButtonTapped(button: UIButton) {
        
        if self.isAnimationPlaying { return }
        
        for node in controlNodes {
            node.removeFromParentNode()
        }
        
        controlNodes.removeAll()
        controlPoints.removeAll()
    }
    
    @objc func popButtonTapped(button: UIButton) {
        
        if self.isAnimationPlaying { return }
        
        if !controlNodes.isEmpty {
            controlNodes.last?.removeFromParentNode()
            controlNodes.removeLast()
        }
        
        if !controlPoints.isEmpty {
            controlPoints.removeLast()
        }
    }
    
    @objc func playButtonTapped(button: UIButton) {
        
        
        if self.isAnimationPlaying { return }
        
        self.isAnimationPlaying = true
        
        ghostNode.isHidden = true
        controlSphere.isHidden = true
        
        if let lastPoint = controlPoints.last {
            let sphereT = ur5.FK(lastPoint)
            
            controlSphere.position = SCNVector3(-sphereT.m41,sphereT.m43,sphereT.m42)
        }
        
        recTransaction(i: 0)
        
    }
    
    func recTransaction(i: Int){
        
        if i == controlPoints.count {

            self.isAnimationPlaying = false
            
            ghostNode.isHidden = false
            controlSphere.isHidden = false
            return
        };
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 3
        
        SCNTransaction.lock()
        ur5.setJoints(controlPoints[i])
        SCNTransaction.unlock()
                   
        SCNTransaction.completionBlock = {
            self.recTransaction(i: i + 1)
        }
        
        SCNTransaction.commit()
        
        
    }
    
    @objc func addButtonTapped(button: UIButton){
        
        if self.isAnimationPlaying { return }
        
        let cloneNode = ur5.baseNode.flattenedClone()
        
        let scale = 1.01
        cloneNode.scale = SCNVector3(scale,scale, scale)
        cloneNode.opacity = 0.3
        
        controlNodes.append(cloneNode)
        controlPoints.append(ur5.getAnglesFromNodes())
        
        self.ghostNode.addChildNode(cloneNode)
        
    }
    
    @objc func handlePan(panGesture: UIPanGestureRecognizer) {
        
        let location = panGesture.location(in: self)
        
        switch panGesture.state {
        case .began:
          
            let hitNodeResult = self.hitTest(location, options: [.searchMode: SCNHitTestSearchMode.all.rawValue])
          
            if hitNodeResult.contains(where: { (r) -> Bool in
                return r.node == controlSphere
            }) {
                isControlSphereSelected = true
            }
            
        case .changed:
        
            if !isControlSphereSelected {break}
            
            let projectedPoint = self.projectPoint(controlSphere.position)
            
            let unprojectedPoint = self.unprojectPoint(SCNVector3(location.x, location.y, CGFloat(projectedPoint.z)))
            
            controlSphere.position = unprojectedPoint
            
            T06.m41 = -controlSphere.position.x
            T06.m42 = controlSphere.position.z
            T06.m43 = controlSphere.position.y

            ur5.setJoints(ur5.IK(T06))
            
        case .ended:
            isControlSphereSelected = false
        default:
          break
        }
    }
}
