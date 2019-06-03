//
//  LivePhotoCaptureProcessor.swift
//  SmileSelfie
//
//  Created by Wu on 2019/5/31.
//  Copyright © 2019 amG. All rights reserved.
//

import AVFoundation

class LivePhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate {
    // ... other PhotoCaptureDelegate methods and supporting properties ...
    
    // A handler to call when Live Photo capture begins and ends.
    var livePhotoStatusHandler: (Bool) -> () = { _ in }
    
    // Call the handler when PhotoCaptureDelegate methods indicate Live Photo capture is in progress.
    
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        let capturingLivePhoto = (resolvedSettings.livePhotoMovieDimensions.width > 0 && resolvedSettings.livePhotoMovieDimensions.height > 0)
        livePhotoStatusHandler(capturingLivePhoto)
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishRecordingLivePhotoMovieForEventualFileAt outputFileURL: URL, resolvedSettings: AVCaptureResolvedPhotoSettings) {
        livePhotoStatusHandler(false)
    }
    
}
