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

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var hoopAdded = false
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        if !hoopAdded {
            let touchLocation = sender.location(in: sceneView)
            let hitTestResult = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])
            
            if let result = hitTestResult.first {
                //addHoop(result: result)
                addTinCanHolder(result: result)
                hoopAdded = true
            }
        } else {
            //createBasketball()
            createTinCan()
        }
        
    }
    
    
    // Adding hoop
    func addHoop(result: ARHitTestResult) {
        // Retrieve the scene file and locate the Hoop node
        let hoopScene = SCNScene(named: "art.scnassets/hop.scn")
        
        guard let hoopNode = hoopScene?.rootNode.childNode(withName: "Hop", recursively: false) else {
            return
        }
        
        // Place the node in the correct position
        let planePosition = result.worldTransform.columns.3
        hoopNode.position = SCNVector3(planePosition.x, planePosition.y, planePosition.z)
        
        // Adding physics with special options to acknowledge the custom shape
        hoopNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: hoopNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
        // Add the node to the scene
        sceneView.scene.rootNode.addChildNode(hoopNode)
    }
    
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
        
        // Adding physics with special options to acknowledge the custom shape
        tinCanHolderNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: tinCanHolderNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        
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
        
        if hoopAdded {
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
        
        if hoopAdded {
            node.opacity = 0.0
        } else {
            node.opacity = 0.5
        }
        
        return node
    }
    
    // Create basketball
    func createBasketball() {
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        let ball = SCNNode(geometry: SCNSphere(radius: 0.25))
        ball.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        //ball.scale = SCNVector3(0.05, 0.05, 0.05)
        
        // Take position of the camera and use it for ball location
        let cameraTransform = SCNMatrix4(currentFrame.camera.transform)
        ball.transform = cameraTransform
        
        // Adding physics, collision margin setes the interaction distance
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: ball, options: [SCNPhysicsShape.Option.collisionMargin: 0.01]))
        ball.physicsBody = physicsBody
        
        let power = Float(10.0)
        let force = SCNVector3(-cameraTransform.m32 * power, -cameraTransform.m32 * power, -cameraTransform.m33 * power)
        
        ball.physicsBody?.applyForce(force, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(ball)
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
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: canNode, options: [SCNPhysicsShape.Option.collisionMargin: 0.01]))
        canNode.physicsBody = physicsBody
        
        let power = Float(10.0)
        let force = SCNVector3(-cameraTransform.m32 * power, -cameraTransform.m32 * power, -cameraTransform.m33 * power)
        
        canNode.physicsBody?.applyForce(force, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(canNode)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
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
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
