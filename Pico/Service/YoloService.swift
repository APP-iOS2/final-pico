//  YoloService.swift
//  Pico
//
//  Created by LJh on 10/16/23.
//
import Foundation
import CoreML
import Vision
import UIKit

final class YoloService {
    var isDetectedImage: Bool? = false
    var objectDetectionRequest: VNCoreMLRequest?

    func loadYOLOv3Model() {
        let configuration = MLModelConfiguration()
        guard let yoloModel = try? VNCoreMLModel(for: YOLOv3(configuration: configuration).model) else {
            fatalError("Failed to load YOLOv3 model.")
        }

        objectDetectionRequest = VNCoreMLRequest(model: yoloModel, completionHandler: { [weak self] request, error in
            self?.isDetectedImage = self?.handleObjectDetectionResults(request: request, error: error)
        })
    }

    func handleObjectDetectionResults(request: VNRequest, error: Error?) -> Bool {
        guard let results = request.results as? [VNRecognizedObjectObservation] else { return false }

        var detectedObjects = ""
        for result in results {
            if let label = result.labels.first {
                if label.identifier == "person" {
                    detectedObjects += "\(label.identifier) (\(String(format: "%.2f", label.confidence * 100))%)\n"
                    if label.confidence * 100 >= 95 {
                        print(label.confidence)
                        return true
                    }
                }
            }
        }
        return false
    }

    func detectPeople(image: UIImage, completion: @escaping () -> ()) {
        guard let cgImage = image.cgImage, let objectDetectionRequest = objectDetectionRequest else { return }

        let request = VNCoreMLRequest(model: objectDetectionRequest.model) { [weak self] request, error in
            self?.isDetectedImage = self?.handleObjectDetectionResults(request: request, error: error)
            completion()
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform object detection: \(error)")
        }
    }
}
