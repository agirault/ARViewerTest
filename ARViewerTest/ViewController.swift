//
//  ViewController.swift
//  ARViewerTest
//
//  Created by Alexis Girault on 10/18/17.
//  Copyright © 2017 Alexis Girault. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var debugSwitch: UISwitch!
    @IBOutlet var instructionsView: UIView!
    @IBOutlet var instructionsLabel: UILabel!

    var config = ARWorldTrackingConfiguration()
    var displayNodes = [SCNNode]()
    var currentDisplayNode: SCNNode?
    var planeNodes = NSMutableDictionary()

    // MARK: - UIView

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupScene()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Run the view's session
        self.sceneView.session.run(self.config)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if planeNodes.count == 0 {
            // Show instructions
            self.instructionsLabel.text = Constants.scanRoomInstructionsLabel
            self.showInstructions(true, 5.0) {};
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Hide instructions
        self.showInstructions(false, 0.0) {};

        // Pause the view's session
        self.sceneView.session.pause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - Setups

    func setupScene() {
        // Setup the session configuration
        self.config.planeDetection = .horizontal

        // Setup scene view
        self.sceneView.delegate = self
        self.sceneView.autoenablesDefaultLighting = true;
        self.sceneView.showsStatistics = Constants.showStatistics
        self.sceneView.debugOptions = self.debugSwitch.isOn ? Constants.debugOptions : []

        // Import mesh from file
        guard let scene = SCNScene(named: Constants.meshFile) else {
            fatalError("Failed to find mesh file")
        }
        self.displayNodes = scene.rootNode.childNodes
        for node in self.displayNodes {
            node.scale = SCNVector3Make(Constants.meshScale, Constants.meshScale, Constants.meshScale)
        }
        //mesh.pivot.m42 = -0.5; // up along -Y
    }

    // MARK: - Callbacks

    // place mesh on touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let touchPt = touch.location(in: self.sceneView)
        let resultType = ARHitTestResult.ResultType.existingPlaneUsingExtent;
        let results = self.sceneView.hitTest(touchPt, types:[resultType])
        if results.count == 0 { return }
        let hitFeature = results.first!
        let hitTransform = SCNMatrix4(hitFeature.worldTransform)

        // If mesh not in scene yet
        if self.currentDisplayNode == nil {
            // Add it to scene
            self.currentDisplayNode = self.displayNodes[0]
            self.sceneView.scene.rootNode.addChildNode(self.currentDisplayNode!)

            // Update instructions
            DispatchQueue.main.async {
                self.showInstructions(false, 0.0) {
                    self.instructionsLabel.text = Constants.meshPlacedInstructionsLabel
                    self.showInstructions(true, 0.0) {
                        self.showInstructions(false, 5.0) {}
                    }
                }
            }
        }

        // Update mesh position
        self.currentDisplayNode!.position = SCNVector3Make(hitTransform.m41,
                                                           hitTransform.m42,
                                                           hitTransform.m43)
    }

    // show/hide debug info
    @IBAction func onDebugSwitch(_ sender: UISwitch) {
        if debugSwitch != sender { return }

        self.sceneView.debugOptions = sender.isOn ? Constants.debugOptions : []
        for (_, planeNode) in planeNodes {
            guard let mat = (planeNode as? SCNPlaneNode)?.geometry?.firstMaterial else { continue }
            mat.colorBufferWriteMask = sender.isOn ? Constants.colorBufferWriteMask : []
        }
    }

    // reset detected anchors
    @IBAction func onResetButtonPressed(_ sender: UIButton) {
        // Empty scene
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        planeNodes.removeAllObjects()

        // Rerun config after removing anchors
        self.sceneView.session.run(self.config, options: [.resetTracking, .removeExistingAnchors])

        // Show instructions
        self.instructionsLabel.text = Constants.scanRoomInstructionsLabel
        self.showInstructions(true, 1.0) {};
    }

    // MARK: - ARSCNViewDelegate

/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()

        return node
    }
*/

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        DispatchQueue.main.async {
            // First plane added, signal how to display the mesh
            if self.planeNodes.count == 0 {
                self.showInstructions(false, 0.0) {
                    self.instructionsLabel.text = Constants.placeMeshInstructionsLabel
                    self.showInstructions(true, 0.0) {};
                }
            }

            // Create a SceneKit plane to visualize the plane anchor using its position and extent.
            let planeNode = SCNPlaneNode(with: planeAnchor, show: self.debugSwitch.isOn)
            node.addChildNode(planeNode)
            self.planeNodes.setObject(planeNode, forKey: anchor.identifier as NSCopying)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        self.planeNodes.removeObject(forKey: anchor.identifier)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeNode = self.planeNodes.object(forKey: anchor.identifier) as? SCNPlaneNode,
              let planeAnchor = anchor as? ARPlaneAnchor
              else { return }
        planeNode.update(with: planeAnchor)
    }

    // MARK: - ARSessionObserver
/*
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
*/

    // MARK: - Utility

    func showInstructions(_ show : Bool, _ delay: TimeInterval, _ completion: @escaping () -> Void) {
        // unhide if showing
        if show {
            self.instructionsView.isHidden = false
        }

        // animate alpha
        UIView.animate(withDuration: 0.5, delay: delay, options: [], animations: {
            self.instructionsView.alpha = show ? 1 : 0
        }, completion: { _ in
            // hide if not showing
            if !show {
                self.instructionsView.isHidden = true
            }
            completion()
        })
    }
}
