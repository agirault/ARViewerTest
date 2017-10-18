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
    var config = ARWorldTrackingConfiguration()

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
        self.sceneView.showsStatistics = true
    }

    // MARK: - ARSCNViewDelegate

/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()

        return node
    }
*/

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
