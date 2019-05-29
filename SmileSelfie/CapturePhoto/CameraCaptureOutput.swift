//
//  CameraCaptureOutput.swift
//  SmileSelfie
//
//  Created by Wu on 2019/5/29.
//  Copyright © 2019 amG. All rights reserved.
//

import UIKit
import AVFoundation

class CameraCaptureOutput: NSObject, AVCapturePhotoCaptureDelegate {
    
    let cameraOutput = AVCapturePhotoOutput()
    
    var flashMode: AVCaptureDevice.FlashMode = .off
    
    var captureCompletion: ((UIImage?) -> ())? = nil
    
    func capturePhoto() {
        
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160]
        settings.flashMode = flashMode
        settings.previewPhotoFormat = previewFormat
        self.cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            //          print(UIImage(data: dataImage)?.size) // Your Image
            if let completion = self.captureCompletion {
                if let image = UIImage(data: dataImage), let cgImage = image.cgImage {
                    let flippedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .leftMirrored)
                    completion(flippedImage)
                }
            }
        }
    }
    
}
