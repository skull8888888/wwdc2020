import UIKit
import PlaygroundSupport
import SceneKit

/*:
 ## UR5 simulation
 Welcome to the interactive simulation of the industrial robot arm - UR5.
 - Experiment:
 To move the end-effector simply long-press an opaque sphere at the end of the robot arm's 'wrist' and drag it around.
*/
/*:
- Important:
There is a certain spherical space reachable by the robot’s ‘wrist’ which is limited by geometry of UR5.  If the user drags a control sphere outside of that workspace robot will stop its movement.
*/
/*:
 - Experiment:
On the control panel press **ADD** button to add a new control point. It will insert a node with an opaque silhouette of the robot arm indicating a saved orientation. Save several positions and then press **PLAY**. The robot arm will sequentially move from one control point to another in the order they were saved. Remove last control point by pressing **POP** and remove all control points with **CLEAR**.
 */

let ur5View = UR5View(frame:  CGRect(x: 0, y: 0, width: 600, height: 600))

PlaygroundPage.current.liveView = ur5View
