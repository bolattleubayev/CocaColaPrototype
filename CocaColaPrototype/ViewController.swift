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
    
    private func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    //create random float between specified ranges
    private func randomFloat(min: Float, max: Float) -> Float {
        return Float.random(in: min...max)
    }
    
    // MARK: - Creating Objects
    
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
                node.position = SCNVector3(randomFloat(min: -10, max: 10), randomFloat(min: -4, max: 5), randomFloat(min: -10, max: 10))
                
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
                node.physicsBody?.categoryBitMask = CollisionCategory.targetCategory.rawValue
                node.physicsBody?.contactTestBitMask = CollisionCategory.missileCategory.rawValue
                
                node.name = nodeName
                
                sceneView.scene.rootNode.addChildNode(node)
            }
        }
    }
    
    // Create tin can
    
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
        objectNode.physicsBody?.categoryBitMask = CollisionCategory.missileCategory.rawValue
        objectNode.physicsBody?.collisionBitMask = CollisionCategory.targetCategory.rawValue
        
        // Force application direction and position
        let (direction, position) = self.getUserVector()
        
        objectNode.name = objectName
        
        objectNode.position = position
        
        // Forc application
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
        
        // enable lighting
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        //configuration.planeDetection = .horizontal
        
        // Run the view's session
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
    
    // MARK: - Collision
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.targetCategory.rawValue
            || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.targetCategory.rawValue {
            
            DispatchQueue.main.async {
                contact.nodeA.removeFromParentNode()
                contact.nodeB.removeFromParentNode()
                
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
            
            let  crash = SCNParticleSystem(named: "Crash", inDirectory: nil)
            contact.nodeB.addParticleSystem(crash!)
        }
    }
    
}

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let missileCategory  = CollisionCategory(rawValue: 1 << 0)
    static let targetCategory = CollisionCategory(rawValue: 1 << 1)
}
