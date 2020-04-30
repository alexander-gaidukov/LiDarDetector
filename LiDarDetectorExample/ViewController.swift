//
//  ViewController.swift
//  LiDarDetectorExample
//
//  Created by Alexandr Gaidukov on 30.04.2020.
//  Copyright © 2020 Alexandr Gaidukov. All rights reserved.
//

import RealityKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var arView: ARView!
    @IBOutlet weak var scanButton: UIButton!
    
    let coachingOverlay = ARCoachingOverlayView()
    
    // Cache for 3D text geometries representing the classification values.
    var modelsForClassification: [ARMeshClassification: ModelEntity] = [:]

    /// - Tag: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView.session.delegate = self
        
        setupCoachingOverlay()

        arView.environment.sceneUnderstanding.options = []
        
        // Turn on occlusion from the scene reconstruction's mesh.
        arView.environment.sceneUnderstanding.options.insert(.occlusion)
        
        // Turn on physics for the scene reconstruction's mesh.
        arView.environment.sceneUnderstanding.options.insert(.physics)

        // Display a debug visualization of the mesh.
        arView.debugOptions.insert(.showSceneUnderstanding)
        
        // For performance, disable render options that are not required for this app.
        arView.renderOptions = [.disablePersonOcclusion, .disableDepthOfField, .disableMotionBlur]
        
        // Manually configure what kind of AR session to run since
        // ARView on its own does not turn on mesh classification.
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .mesh
        configuration.environmentTexturing = .automatic
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Prevent the screen from being dimmed to avoid interrupting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func scanButtonPressed(_ sender: Any) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Unable to create MTLDevice")
            return
        }
        
        guard let meshAnchors = arView.session.currentFrame?.anchors.compactMap({ $0 as? ARMeshAnchor }) else { return }
        
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0];
        let filename = directory.appendingPathComponent("MyFirstMesh.obj");
        
        do {
            try meshAnchors.save(to: filename, device: device)
            let activityViewController = UIActivityViewController(activityItems: [filename], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = scanButton
            present(activityViewController, animated: true, completion: nil)
        } catch {
            print("Unable to save mesh")
        }
    }
}
