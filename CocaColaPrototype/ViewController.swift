//
//  ViewController.swift
//  ARShots
//
//  Created by macbook on 2/23/20.
//  Copyright © 2020 bolattleubayev. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    private var isCan = true
    private var score = 0
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBAction func changeObjectMode(_ sender: UISegmentedControl) {
        DispatchQueue.main.async {
          switch sender.selectedSegmentIndex {
          case 0:
            self.isCan = true
          case 1:
            self.isCan = false
          default:
              break
          }
        }
    }
    
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        
        if isCan {
            createThrownObject(objectName: "can")
        } else {
            createThrownObject(objectName: "bottle")
        }
        
    }
    
    // MARK: - Force Direction
    
    private func getCameraTransformationVectors() -> (SCNVector3, SCNVector3) {
        
        if let currentFrame = self.sceneView.session.currentFrame {
            
            let cameraInTheWorldMatrix = SCNMatrix4(currentFrame.camera.transform)
            let cameraOrientation = SCNVector3(-1 * cameraInTheWorldMatrix.m31, -1 * cameraInTheWorldMatrix.m32, -1 * cameraInTheWorldMatrix.m33)
            let cameraPosition = SCNVector3(cameraInTheWorldMatrix.m41, cameraInTheWorldMatrix.m42, cameraInTheWorldMatrix.m43)
            
            return (cameraOrientation, cameraPosition)
        }
        
        return (SCNVector3(0, -1, 0), SCNVector3(0, 0, -0.5))
    }
    
    // MARK: - Creating Objects
    
    // Catching Bins
    private func addBins() {
        
        for _ in 0..<30 {
            
            // Generate random bin type
            let randomBinIndex = Bool.random()
            var holedrName = ""
            var nodeName = ""
            if randomBinIndex {
                holedrName = "art.scnassets/tinCanHolder.scn"
                nodeName = "canBasket"
            } else {
                holedrName = "art.scnassets/bottleHolder.scn"
                nodeName = "bottleBasket"
            }
            
            let tinCanHolderScene = SCNScene(named: holedrName)
            
            if let node = tinCanHolderScene?.rootNode.childNode(withName: "Bin", recursively: false) {
                
                // Locate bins at random positions
                
                node.position = SCNVector3(Float.random(in: -8...9), Float.random(in: -3...6), Float.random(in: -9...8))
                
                node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
                node.physicsBody?.isAffectedByGravity = false
                
                // Add animation
                
                let rotationAction : SCNAction = SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 2.0)
                
                let scaleUpAction: SCNAction = SCNAction.scale(to: 1.2, duration: 1.0)
                let scaleDownAction: SCNAction = SCNAction.scale(by: 1.2, duration: 1.0)
                
                let actionSequence = SCNAction.sequence([scaleUpAction, scaleDownAction])
                let groupedAction = SCNAction.group([rotationAction, actionSequence])
                
                let repeatedGroupAction = SCNAction.repeatForever(groupedAction)
                
                node.runAction(repeatedGroupAction)
                
                // Collision
                node.physicsBody?.categoryBitMask = CollidingObjectType.catchingObject.rawValue
                node.physicsBody?.contactTestBitMask = CollidingObjectType.thrownObject.rawValue
                
                node.name = nodeName
                
                sceneView.scene.rootNode.addChildNode(node)
            }
        }
    }
    
    // Thrown cans or bottles
    private func createThrownObject(objectName: String) {
        
        var scnFileName = ""
        var sceneGraphName = ""
        var torque = 0.0
        
        if objectName == "can" {
            scnFileName = "art.scnassets/tinCan.scn"
            sceneGraphName = "Can"
            torque = 0.01
        } else {
            scnFileName = "art.scnassets/bottle.scn"
            sceneGraphName = "Bottle"
            torque = 0.03
        }
        
        let objectScene = SCNScene(named: scnFileName)
        
        guard let objectNode = objectScene?.rootNode.childNode(withName: sceneGraphName, recursively: false) else {
            return
        }
        
        // Creat Physics Body
        objectNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        objectNode.physicsBody?.isAffectedByGravity = false
        
        // Collision properties
        objectNode.physicsBody?.categoryBitMask = CollidingObjectType.thrownObject.rawValue
        objectNode.physicsBody?.collisionBitMask = CollidingObjectType.catchingObject.rawValue
        
        // Force application direction and position
        let (direction, position) = self.getCameraTransformationVectors()
        
        objectNode.name = objectName
        
        objectNode.position = position
        
        // Force application
        let force = SCNVector3(direction.x*4,direction.y*4,direction.z*4)
        objectNode.physicsBody?.applyForce(force, asImpulse: true)
        objectNode.physicsBody?.applyTorque(SCNVector4(1, 1, 1, torque), asImpulse: true)
        
        
        sceneView.scene.rootNode.addChildNode(objectNode)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        self.sceneView.scene.physicsWorld.contactDelegate = self
        
        addBins()
        
        // Enable default lighting
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - Collision handling
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        if contact.nodeA.physicsBody?.categoryBitMask == CollidingObjectType.catchingObject.rawValue
            || contact.nodeB.physicsBody?.categoryBitMask == CollidingObjectType.catchingObject.rawValue {
            
            // Dispatching to main queue asynchronously
            DispatchQueue.main.async {
                contact.nodeA.removeFromParentNode()
                contact.nodeB.removeFromParentNode()
                
                // Score counting logic
                if ((contact.nodeA.name! == "canBasket" && contact.nodeB.name! == "can") || (contact.nodeA.name! == "can" && contact.nodeB.name! == "canBasket")) {
                    self.score += 10
                    self.scoreLabel.text = String("Счёт: \(self.score)")
                } else if ((contact.nodeA.name! == "bottleBasket" && contact.nodeB.name! == "bottle") || (contact.nodeA.name! == "bottle" && contact.nodeB.name! == "bottleBasket")) {
                    self.score += 10
                    self.scoreLabel.text = String("Счёт: \(self.score)")
                } else {
                    self.scoreLabel.text = String("Счёт: \(self.score)")
                }
                
            }
            
            // Crash animation
            let  crash = SCNParticleSystem(named: "Crash", inDirectory: nil)
            contact.nodeB.addParticleSystem(crash!)
        }
    }
    
}

struct CollidingObjectType: OptionSet {
    
    let rawValue: Int
    
    static let thrownObject  = CollidingObjectType(rawValue: 1 << 0)
    static let catchingObject = CollidingObjectType(rawValue: 1 << 1)
    
}
