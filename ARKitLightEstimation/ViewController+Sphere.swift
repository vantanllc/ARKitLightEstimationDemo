//
//  ViewController+Sphere.swift
//  ARKitLightEstimation
//
//  Created by Thinh Luong on 5/6/18.
//  Copyright © 2018 Jayven Nhan. All rights reserved.
//

import ARKit

extension ViewController {
  func getSphere(withPosition position: SCNVector3) -> SCNNode {
    let sphere = SCNSphere(radius: 0.1)
    let sphereNode = SCNNode(geometry: sphere)
    sphereNode.position = position
    sphereNode.position.y += Float(sphere.radius) + 0.1
    
    return sphereNode
  }
  
  func getLightNode() -> SCNNode {
    let light = SCNLight()
    light.type = .omni
    light.intensity = 0
    light.temperature = 0
    
    let lightNode = SCNNode()
    lightNode.light = light
    lightNode.position = SCNVector3(0, 1, 0)
    
    return lightNode
  }
  
  func addLightNodeTo(_ node: SCNNode) {
    let lightNode = getLightNode()
    node.addChildNode(lightNode)
    lightNodes.append(lightNode)
  }
  
  func updateLightNodesLightEstimation() {
    DispatchQueue.main.async {
      guard self.lightEstimationSwitch.isOn,
        let lightEstimate = self.sceneView.session.currentFrame?.lightEstimate else { return }
      
      let ambientIntensity = lightEstimate.ambientIntensity
      let ambientColorTemperature = lightEstimate.ambientColorTemperature
      
      for lightNode in self.lightNodes {
        guard let light = lightNode.light else { continue }
        
        light.intensity = ambientIntensity
        light.temperature = ambientColorTemperature
      }
    }
  }
}
