//
//  Constants.swift
//  ARViewerTest
//
//  Created by Alexis Girault on 10/27/17.
//  Copyright © 2017 Alexis Girault. All rights reserved.
//

import ARKit

struct Constants {
    static let meshFile = "art.scnassets/cardiac.dae"
    static let meshScale = 0.2 as Float

    static let showStatistics = false
    static let debugOptions = ARSCNDebugOptions.showFeaturePoints
    static let colorBufferWriteMask = [.red, .green, .blue, .alpha] as SCNColorMask
    static let planesOpacity = 0.5 as CGFloat

    static let scanRoomInstructionsLabel = "👋 Hey! Look around a bit more..."
    static let placeMeshInstructionsLabel = "🎉 Neat! Now tap somewhere flat."
    static let meshPlacedInstructionsLabel = "🚀 Yahooo!"
}
