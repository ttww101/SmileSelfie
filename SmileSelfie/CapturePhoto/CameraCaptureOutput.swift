//
//  CameraCaptureOutput.swift
//  SmileSelfie
//
//  Created by Wu on 2019/5/29.
//  Copyright © 2019 amG. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import PhotosUI
import MobileCoreServices

class CameraCaptureOutput: NSObject, AVCapturePhotoCaptureDelegate {
    
    let cameraOutput = AVCapturePhotoOutput()
    
    var currentDevicePosition:AVCaptureDevice.Position = .front
    
    var flashMode: AVCaptureDevice.FlashMode = .off
    
    var captureCompletion: ((UIImage?) -> ())? = nil
    
    var stillImageData: Data? = nil
    
    var livePhotosInProgress = 0 {
        didSet {
//            self.capturingLivePhotoLabel.isHidden = (livePhotosInProgress > 0)
        }
    }
    
    func capturePhoto() {
        if (self.cameraOutput.isLivePhotoCaptureEnabled) {
            self.captureLivePhoto()
        } else {
            self.captureNormalPhoto()
        }
    }
    
    func captureNormalPhoto() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160,
                             ]
        settings.flashMode = flashMode
        settings.previewPhotoFormat = previewFormat
        
        settings.flashMode = flashMode
        settings.previewPhotoFormat = previewFormat
        self.cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func captureLivePhoto() {
        //live photo path change
        var livePhotoCount = 0
        if let count = UserDefaults.standard.value(forKey: SmileSelfieKey.livePhotoCount) as? Int {
            livePhotoCount = count + 1
        }
        UserDefaults.standard.setValue(livePhotoCount, forKey: SmileSelfieKey.livePhotoCount)
        
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        self.cameraOutput.isHighResolutionCaptureEnabled = true
        
        if let videoOutputConnection = self.cameraOutput.connection(with: .video) {
            if self.cameraOutput.isLivePhotoCaptureEnabled == true && self.currentDevicePosition == .front {
                if videoOutputConnection.isVideoMirroringSupported == true {
                    videoOutputConnection.automaticallyAdjustsVideoMirroring = false
                    videoOutputConnection.isVideoMirrored = true
                }
            }
        }
        photoSettings.livePhotoMovieFileURL = URL(fileURLWithPath:  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]+"/smile_selfie_live_photo_\(livePhotoCount).mov")
        
        let captureProcessor = LivePhotoCaptureProcessor()
        captureProcessor.livePhotoStatusHandler = { isCapturing in
            self.livePhotosInProgress += (isCapturing ? +1 : -1)
        }
        
        self.cameraOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation()  else { return }
        self.stillImageData = imageData
        //save normal photo
        if let completion = self.captureCompletion {
            completion(self.turnToRightImage(with: UIImage(data: imageData)))
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            print("Error capturing Live Photo movie: \(error)")
            return
        }
        guard let stillImageData = self.stillImageData else { return }
        
        self.saveLivePhotoToPhotosLibrary(stillImageData: stillImageData,
                                          livePhotoMovieURL: outputFileURL)
    }
    
    func saveLivePhotoToPhotosLibrary(stillImageData: Data, livePhotoMovieURL: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                
                creationRequest.addResource(with: .photo, data: stillImageData, options: nil)
                let options = PHAssetResourceCreationOptions()
                options.shouldMoveFile = true
                creationRequest.addResource(with: .pairedVideo, fileURL: livePhotoMovieURL, options: options)
            }, completionHandler: { isComplete, error in
                if isComplete {
                    print("success, save live photo")
                } else {
                    print("failed, save live photo")
                }
            })
        }
    }
    
}

//MARK: private method
extension CameraCaptureOutput {
    func turnToRightImage(with image: UIImage?) -> UIImage? {
        if let image = image, let cgImage = image.cgImage {
            
            var completionImage: UIImage? = nil
            switch currentDevicePosition {
            case .back:
                completionImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .right)
                break
                
            default:
                completionImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .leftMirrored)
                break
            }
            return completionImage
        } else {
            return nil
        }
    }
}
