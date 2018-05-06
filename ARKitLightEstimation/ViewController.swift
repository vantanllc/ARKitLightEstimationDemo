//
//  ViewController.swift
//  ARKitLightDemo
//
//  Created by Jayven Nhan on 1/25/18.
//  Copyright © 2018 Jayven Nhan. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
  
  @IBOutlet weak var sceneView: ARSCNView!
  @IBOutlet weak var instructionLabel: UILabel!
  
  @IBOutlet weak var mainStackView: UIStackView!
  @IBOutlet weak var lightEstimationStackView: UIStackView!
  
  @IBOutlet weak var ambientIntensityLabel: UILabel!
  @IBOutlet weak var ambientColorTemperatureLabel: UILabel!
  
  @IBOutlet weak var ambientIntensitySlider: UISlider!
  @IBOutlet weak var ambientColorTemperatureSlider: UISlider!
  
  @IBOutlet weak var lightEstimationSwitch: UISwitch!
  
  var lightNodes = [SCNNode]()
  
  var detectedHorizontalPlane = false {
    didSet {
      DispatchQueue.main.async {
        self.mainStackView.isHidden = !self.detectedHorizontalPlane
        self.instructionLabel.isHidden = self.detectedHorizontalPlane
        self.lightEstimationStackView.isHidden = !self.detectedHorizontalPlane
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setUpSceneView()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    sceneView.session.pause()
  }
  
  func setUpSceneView() {
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    sceneView.session.run(configuration)
    sceneView.delegate = self
  }
  
  @IBAction func ambientIntensitySliderValueDidChange(_ sender: UISlider) {
    DispatchQueue.main.async {
      let ambientIntensity = sender.value
      self.ambientIntensityLabel.text = "Ambient Intensity: \(ambientIntensity)"
    
      guard !self.lightEstimationSwitch.isOn else {return}
      
      for lightNode in self.lightNodes {
        guard let light = lightNode.light else {continue}
        light.intensity = CGFloat(ambientIntensity)
      }
    }
  }
  
  @IBAction func ambientColorTemperatureSliderValueDidChange(_ sender: UISlider) {
    DispatchQueue.main.async {
      let ambientColorTemperature = sender.value
      self.ambientColorTemperatureLabel.text = "Ambient Color Temperature: \(ambientColorTemperature)"
      
      guard !self.lightEstimationSwitch.isOn else {return}
      
      for lightNode in self.lightNodes {
        guard let light = lightNode.light else {continue}
        light.temperature = CGFloat(ambientColorTemperature)
      }
    }
  }
  
  @IBAction func lightEstimationSwitchValueDidChange(_ sender: UISwitch) {
    ambientIntensitySliderValueDidChange(ambientIntensitySlider)
    ambientColorTemperatureSliderValueDidChange(ambientColorTemperatureSlider)
  }
  
}

extension ViewController: ARSCNViewDelegate {
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    let planeAnchorCenter = SCNVector3(planeAnchor.center)
    
    let sphere = getSphere(withPosition: planeAnchorCenter)
    addLightNodeTo(sphere)
    node.addChildNode(sphere)
    detectedHorizontalPlane = true
  }
  
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    updateLightNodesLightEstimation()
  }
}

extension float4x4 {
  var translation: float3 {
    let translation = self.columns.3
    return float3(translation.x, translation.y, translation.z)
  }
}

