//
//  ARPlane.swift
//  ARViewerTest
//
//  Created by Alexis Girault on 10/27/17.
//  Copyright © 2017 Alexis Girault. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class SCNPlaneNode: SCNNode {
    public let anchor: ARPlaneAnchor

    init(with planeAnchor: ARPlaneAnchor, show: Bool) {
        self.anchor = planeAnchor
        super.init()

        self.geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                 height: CGFloat(planeAnchor.extent.z))

        // Update material
        let mat = self.geometry!.firstMaterial
        mat?.colorBufferWriteMask = show ? Constants.colorBufferWriteMask : []
        mat?.diffuse.contents = UIColor.random()
        mat?.lightingModel = .constant

        self.renderingOrder = -1
        self.opacity = Constants.planesOpacity
        self.simdPosition = planeAnchor.center
        self.eulerAngles.x = -.pi / 2 // vertically oriented in its local coordinates -> rotate to horizontal
    }

    func update(with planeAnchor: ARPlaneAnchor) {
        self.simdPosition = planeAnchor.center
        guard let plane = self.geometry as? SCNPlane else {
            fatalError("Can't update geometry that isn't a plane")
        }
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class doesn't support NSCoding.")
    }
}
