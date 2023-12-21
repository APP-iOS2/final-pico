//
//  VisionService.swift
//  Pico
//
//  Created by 최하늘 on 12/15/23.
//

import CoreML
import Vision
import UIKit

final class VisionService {
    private var faceDetectionRequest: VNDetectFaceRectanglesRequest?
    
    init() {
        faceDetectionRequest = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let self else { return }
            _ = handleFaceDetectionResults(request: request, error: error)
        }
    }
    
    func handleFaceDetectionResults(request: VNRequest, error: Error?) -> Bool {
        guard let results = request.results as? [VNFaceObservation] else { return false }
        print("faceCount : \(results.count)")
        guard results.isEmpty else {
            return true
        }
        return false
    }
    
    func detectFaces(image: UIImage, completion: @escaping (Bool) -> ()) {
        guard let ciImage = CIImage(image: image) else {
            completion(false)
            return
        }
        
        let request = VNDetectFaceRectanglesRequest { res, err in
            completion(self.handleFaceDetectionResults(request: res, error: err))
        }
        #if targetEnvironment(simulator)
           request.usesCPUOnly = true
        #endif
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform face detection: \(error)")
        }
    }
}
