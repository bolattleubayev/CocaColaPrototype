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
    
    var basketAdded = false
    var isCan = true
    
    
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
        if !basketAdded {
            let touchLocation = sender.location(in: sceneView)
            let hitTestResult = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])
            
            if let result = hitTestResult.first {
                addTinCanHolder(result: result)
                basketAdded = true
                    
            }
        } else {
            //createBasketball()
            if isCan {
                createTinCan()
            } else {
                createBottle()
            }
        }
        
    }
    
    // MARK: - Force Direction
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    // MARK: - Creating Objects
    
    // Adding tin can holder
    func addTinCanHolder(result: ARHitTestResult) {
        // Retrieve the scene file and locate the Hoop node
        let tinCanHolderScene = SCNScene(named: "art.scnassets/tinCanHolder.scn")
        
        guard let tinCanHolderNode = tinCanHolderScene?.rootNode.childNode(withName: "TinCan", recursively: false) else {
            return
        }
        
        // Place the node in the correct position
        let planePosition = result.worldTransform.columns.3
        tinCanHolderNode.position = SCNVector3(planePosition.x, planePosition.y, planePosition.z)
        
        tinCanHolderNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        tinCanHolderNode.physicsBody?.isAffectedByGravity = false
        
        tinCanHolderNode.physicsBody?.categoryBitMask = CollisionCategory.targetCategory.rawValue
        tinCanHolderNode.physicsBody?.contactTestBitMask = CollisionCategory.missileCategory.rawValue
        
        // Add the node to the scene
        sceneView.scene.rootNode.addChildNode(tinCanHolderNode)
    }
    
    // Create vertical areas
    func createVerticalArea(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode()
        
        let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        geometry.firstMaterial?.diffuse.contents = UIColor.green
        node.geometry = geometry
        
        node.eulerAngles.x = -.pi / 2
        
        if basketAdded {
            node.opacity = 0.0
        } else {
            node.opacity = 0.5
        }
        
        return node
    }
    
    // Create horizontal areas
    func createHorizontalArea(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode()
        
        let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        geometry.firstMaterial?.diffuse.contents = UIColor.green
        node.geometry = geometry
        
        node.eulerAngles.x = -.pi / 2
        
        if basketAdded {
            node.opacity = 0.0
        } else {
            node.opacity = 0.5
        }
        
        return node
    }
    
    
    // Create tin can
    
    func createTinCan() {
        let canScene = SCNScene(named: "art.scnassets/tinCan.scn")
        
        guard let canNode = canScene?.rootNode.childNode(withName: "Can", recursively: false) else {
            return
        }
        
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        // Take position of the camera and use it for ball location
        let cameraTransform = SCNMatrix4(currentFrame.camera.transform)
        canNode.transform = cameraTransform
        
        // Adding physics, collision margin setes the interaction distance
        //let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: canNode, options: [SCNPhysicsShape.Option.collisionMargin: 0.01]))
        //canNode.physicsBody = physicsBody
        
        //canNode.physicsBody?.categoryBitMask = CollisionCategory.flier.rawValue
        
        canNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        canNode.physicsBody?.isAffectedByGravity = false
        
        canNode.physicsBody?.categoryBitMask = CollisionCategory.missileCategory.rawValue
        canNode.physicsBody?.collisionBitMask = CollisionCategory.targetCategory.rawValue
        //canNode.physicsBody?.contactTestBitMask = BodyType.flier.rawValue
        
        let (direction, position) = self.getUserVector()
        
        canNode.position = position
        //let force = SCNVector3(-cameraTransform.m32 * power, -cameraTransform.m32 * power, -cameraTransform.m33 * power)
        let force = SCNVector3(direction.x*4,direction.y*4,direction.z*4)
        canNode.physicsBody?.applyForce(force, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(canNode)
    }
    
    // Create bottle
    
    func createBottle() {
        let canScene = SCNScene(named: "art.scnassets/bottle.scn")
        
        guard let canNode = canScene?.rootNode.childNode(withName: "Bottle", recursively: false) else {
            return
        }
        
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        // Take position of the camera and use it for ball location
        let cameraTransform = SCNMatrix4(currentFrame.camera.transform)
        canNode.transform = cameraTransform
        
        // Adding physics, collision margin setes the interaction distance
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: canNode, options: [SCNPhysicsShape.Option.collisionMargin: 0.01]))
        canNode.physicsBody = physicsBody
        
        //canNode.physicsBody?.categoryBitMask = BodyType.flier.rawValue
        //canNode.physicsBody?.contactTestBitMask = BodyType.flier.rawValue
        
        let (direction, position) = self.getUserVector()
        
        canNode.position = position
        //let force = SCNVector3(-cameraTransform.m32 * power, -cameraTransform.m32 * power, -cameraTransform.m33 * power)
        let force = SCNVector3(direction.x*4,direction.y*4,direction.z*4)
        canNode.physicsBody?.applyForce(force, asImpulse: true)
        
        sceneView.scene.rootNode.addChildNode(canNode)
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        self.sceneView.scene.physicsWorld.contactDelegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/hop.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
        
        // Show the world origin
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        // enable lighting
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    // Adding new planes
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        if planeAnchor.alignment == .vertical {
            //let verticalPlane = createVerticalArea(planeAnchor: planeAnchor)
            //node.addChildNode(verticalPlane)
        } else {
            let horizontalPlane = createHorizontalArea(planeAnchor: planeAnchor)
            node.addChildNode(horizontalPlane)
        }
    }
    
     // Merging planes that are close to each other
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        for node in node.childNodes {
            node.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            if let plane = node.geometry as? SCNPlane {
                plane.width = CGFloat(planeAnchor.extent.x)
                plane.height = CGFloat(planeAnchor.extent.z)
            }
        }
    }
    
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
        
        
        print("Collision")
        //print("** Collision!! " + contact.nodeA.name! + " hit " + contact.nodeB.name!)
        
        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.targetCategory.rawValue
            || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.targetCategory.rawValue {
            
            basketAdded = false
            
            DispatchQueue.main.async {
                contact.nodeA.removeFromParentNode()
                contact.nodeB.removeFromParentNode()
                self.scoreLabel.text = String("Collision!")
            }
            
            let  explosion = SCNParticleSystem(named: "Explode", inDirectory: nil)
            contact.nodeB.addParticleSystem(explosion!)
        }
    }
    
}

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let missileCategory  = CollisionCategory(rawValue: 1 << 0)
    static let targetCategory = CollisionCategory(rawValue: 1 << 1)
    static let otherCategory = CollisionCategory(rawValue: 1 << 2)
}
