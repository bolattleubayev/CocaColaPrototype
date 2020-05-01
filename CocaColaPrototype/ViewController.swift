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
    
    let defaults = UserDefaults.standard
    private var isCan = true
    private var score = 0
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var aimImageView: UIImageView!
    @IBOutlet weak var objectModeSelector: UISegmentedControl!
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
    
    @IBAction func restartButtonPressed(_ sender: UIButton) {
        
        // Remove all previously added nodes
        for childNode in sceneView.scene.rootNode.childNodes {
            childNode.removeFromParentNode()
        }
        
        // Add bins
        addBins()
        
        score = 0
        
        scoreLabel.text = "Счёт: \(self.score)"
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
                
                let scaleUpAction: SCNAction = SCNAction.scale(to: 1.1, duration: 1.0)
                let scaleDownAction: SCNAction = SCNAction.scale(by: 1.1, duration: 1.0)
                
                let actionSequence = SCNAction.sequence([scaleUpAction, scaleDownAction])
                let groupedAction = SCNAction.group([rotationAction, actionSequence])
                
                let repeatedGroupAction = SCNAction.repeatForever(groupedAction)
                
                node.runAction(repeatedGroupAction)
                
                // Collision properties
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
        
        // Apply random torque
        objectNode.physicsBody?.applyTorque(SCNVector4(Double.random(in: 0...1), Double.random(in: 0...1), Double.random(in: 0...1), torque), asImpulse: true)
        
        
        sceneView.scene.rootNode.addChildNode(objectNode)
    }
    
    // QR
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            self.scoreLabel.text = "Вы нашли специальный QR код +10 баллов на доске почета"
            self.defaults.set(self.defaults.integer(forKey: "localScore") + 10, forKey: "localScore")
        
        }
        print(defaults.integer(forKey: "localScore"))
        guard let imageAnchor = anchor as? ARImageAnchor else {
            return
        }
        
        let referenceImage = imageAnchor.referenceImage
        
        //let plane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
        //plane.firstMaterial?.diffuse.contents = UIColor.blue
        //let planeNode = SCNNode(geometry: plane)
        //planeNode.eulerAngles.x = -Float.pi / 2
        //planeNode.opacity = 0.5
        
        let pyramidScene = SCNScene(named: "art.scnassets/pyramid.scn")
        
        guard let pyramidNode = pyramidScene?.rootNode.childNode(withName: "parent", recursively: false) else {
            return
        }
        
        // Place the node in the correct position
        pyramidNode.position = node.position
        //pyramidNode.eulerAngles.x = .pi/2
        // Add the node to the scene
        //planeNode.addChildNode(pyramidNode)
        
        pyramidNode.runAction(.group([.fadeOpacity(to: 1.0, duration: 1.5), .rotateBy(x: 0, y: .pi * 2, z: 0, duration: 3)]))
        
        node.addChildNode(pyramidNode)
        //planeNode.runAction(waitRemoveAction)
    }
    
    var waitRemoveAction: SCNAction {
        return .sequence([.wait(duration: 5.0), .fadeOut(duration: 2.0), .removeFromParentNode()])
    }
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if defaults.integer(forKey: "gameMode") == 0 {
            scoreLabel.text = "Счёт: \(self.score)"
            // If Game mode
            aimImageView.isHidden = false
            objectModeSelector.isHidden = false
            
            self.sceneView.scene.physicsWorld.contactDelegate = self
            
            addBins()
            
            // Enable default lighting
            sceneView.autoenablesDefaultLighting = true
            
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            sceneView.session.run(configuration)
        } else {
            // QR mode
            scoreLabel.text = "QR режим"
            aimImageView.isHidden = true
            objectModeSelector.isHidden = true
            
            let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)!
            
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            configuration.detectionImages = referenceImages
            
            // Enable default lighting
            sceneView.autoenablesDefaultLighting = true
            
            // Run the view's session
            sceneView.session.run(configuration, options: [])
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        score = 0
        for child in sceneView.scene.rootNode.childNodes {
            child.removeFromParentNode()
        }
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
                    self.scoreLabel.text = "Счёт: \(self.score)"
                } else if ((contact.nodeA.name! == "bottleBasket" && contact.nodeB.name! == "bottle") || (contact.nodeA.name! == "bottle" && contact.nodeB.name! == "bottleBasket")) {
                    self.score += 10
                    self.scoreLabel.text = "Счёт: \(self.score)"
                } else {
                    self.scoreLabel.text = "Счёт: \(self.score)"
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
