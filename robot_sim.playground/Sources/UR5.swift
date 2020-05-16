import Foundation
import SceneKit

public class UR5 {
    
    enum Safe: Scalar {
        case inner = 0.15
        case outer = 0.84
    }
    
    private let d1: Scalar = 0.089159
    
    private let a2: Scalar = 0.425
    private let a3: Scalar = 0.39225
    
    private let d4: Scalar = 0.10915
    private let d5: Scalar = 0.09465
    private let d6: Scalar = 0.12
    
    public weak var baseNode: SCNNode!
    weak var shoulderNode: SCNNode!
    weak var upperarmNode: SCNNode!
    weak var forearmNode: SCNNode!
    weak var wrist1Node: SCNNode!
    weak var wrist2Node: SCNNode!
    weak var wrist3Node: SCNNode!
        
    public init(scene: SCNScene) {
        
        baseNode = scene.rootNode.childNode(withName:"base_link", recursively: true)!
        shoulderNode = scene.rootNode.childNode(withName:"shoulder_link", recursively: true)!
        upperarmNode = scene.rootNode.childNode(withName:"upperarm_link", recursively: true)!
        forearmNode = scene.rootNode.childNode(withName:"forearm_link", recursively: true)!
        wrist1Node = scene.rootNode.childNode(withName:"wrist1_link", recursively: true)!
        wrist2Node = scene.rootNode.childNode(withName:"wrist2_link", recursively: true)!
        wrist3Node = scene.rootNode.childNode(withName:"wrist3_link", recursively: true)!
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func calcT01(_ theta1: Scalar) -> Matrix4 {
        return Matrix4(rotation: Vector4(0,0,1,theta1)) * Matrix4(translation: Vector3(0,0,d1)) * Matrix4(rotation: Vector4(1,0,0,.pi/2))
    }
    
    func calcT12(_ theta2: Scalar) -> Matrix4 {
        return Matrix4(rotation: Vector4(0,0,1,theta2)) * Matrix4(translation: Vector3(-a2,0,0))
    }
    
    func calcT23(_ theta3: Scalar) -> Matrix4 {
        return Matrix4(rotation: Vector4(0,0,1,theta3)) * Matrix4(translation: Vector3(-a3,0,0))
    }
    
    func calcT34(_ theta4: Scalar) -> Matrix4 {
        return Matrix4(rotation: Vector4(0,0,1,theta4)) * Matrix4(translation: Vector3(0,0,d4)) * Matrix4(rotation: Vector4(1,0,0,.pi/2))
    }
    
    func calcT45(_ theta5: Scalar) -> Matrix4 {
        return Matrix4(rotation: Vector4(0,0,1,theta5)) * Matrix4(translation: Vector3(0,0,d5)) * Matrix4(rotation: Vector4(1,0,0,-.pi/2))
    }
    
    func calcT56(_ theta6: Scalar) -> Matrix4 {
        return Matrix4(rotation: Vector4(0,0,1,theta6)) * Matrix4(translation: Vector3(0,0,d6))
    }
    
    public func FK(_ t: [Scalar]) -> Matrix4 {
        return calcT01(t[0]) * calcT12(t[1]) * calcT23(t[2]) * calcT34(t[3]) * calcT45(t[4]) * calcT56(t[5])
    }
    
    public func getAnglesFromNodes() -> [Scalar]{
        return [
            shoulderNode.eulerAngles.y,
            -upperarmNode.eulerAngles.z - .pi/2,
            -forearmNode.eulerAngles.z,
            -wrist1Node.eulerAngles.z - .pi/2,
            wrist2Node.eulerAngles.y,
            wrist3Node.eulerAngles.z
        ]
    }
    
    public func setJoints(_ t: [Scalar]){
        
        if t.isEmpty { return }
        
        for angle in t {
            if angle.isNaN { return }
        }
        
        shoulderNode?.eulerAngles.y = t[0]
        upperarmNode?.eulerAngles.z = -t[1] - .pi/2
        forearmNode?.eulerAngles.z = -t[2]
        wrist1Node?.eulerAngles.z = -t[3] - .pi/2
        wrist2Node?.eulerAngles.y = t[4]
        wrist3Node?.eulerAngles.z = t[5]
    }
        
    public func IK(_ T06: Matrix4) -> [Scalar] {
        
        if !isInWorkspace(T06) { return [] }
        
        // calculatin theta 1
        let p5 = T06 * Vector4(0,0,-d6,1)
        let theta1 = atan2(p5.y, p5.x) + acos(d4/p5.xy.length) + .pi/2
        
        // calculating theta 5
        let p6 = Vector3(T06.m41, T06.m42, T06.m43)
        let theta5 = -acos((p6.x*sin(theta1) - p6.y*cos(theta1) - d4)/d6)

        // calculating theta 6
        let T01 = calcT01(theta1)
        //print(T01)
        let T61 = T06.inverse * T01
        
        let theta6 = atan2(-T61.m32/sin(theta5), T61.m31/sin(theta5))

        // calculating theta 3

        let a2: Scalar = 0.425
        let a3: Scalar = 0.39225

        let T56 = calcT56(theta6)
        let T45 = calcT45(theta5)

        let T46 = T45 * T56
        let T14 = T01.inverse * T06 * T46.inverse
        let p13 = T14 * Vector4(0,-d4,0,1) - Vector4(0,0,0,1)
        
        let theta3 = acos((p13.lengthSquared - a2*a2 - a3*a3) / (2*a2*a3))
        
        // calculating theta 2
        let theta2 = -(atan2(p13.y, -p13.x) + asin((a3 * sin(theta3)/p13.length)))


        // calculating theta 4
        let T12 = calcT12(theta2)
        let T23 = calcT23(theta3)

        let T34 = (T12 * T23).inverse * T14

        let theta4 = atan2(T34.m12, T34.m11)
        
        return [theta1, theta2, theta3, theta4, theta5, theta6]
    }
    
    func isInWorkspace(_ m: Matrix4) -> Bool {
        
        let p = Vector3(m.m41,m.m42,m.m43)
        
        if p.xy.length <= Safe.inner.rawValue || p.length >= Safe.outer.rawValue || p.z <= 0 { return false }
        
        return true
        
    }
    
}
