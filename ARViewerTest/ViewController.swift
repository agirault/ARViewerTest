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

    var config = ARWorldTrackingConfiguration()
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

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
        self.sceneView.showsStatistics = Constants.showStatistics
        self.sceneView.debugOptions = self.debugSwitch.isOn ? Constants.debugOptions : []
    }

    // MARK: - Callbacks

    // show/hide debug info
    @IBAction func onDebugSwitch(_ sender: UISwitch) {
        if debugSwitch != sender { return }

        self.sceneView.debugOptions = sender.isOn ? Constants.debugOptions : []
        for (_, planeNode) in planeNodes {
            (planeNode as? SCNPlaneNode)?.isHidden = !sender.isOn
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
}
