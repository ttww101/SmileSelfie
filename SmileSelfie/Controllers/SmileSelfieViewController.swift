//
//  SmileSelfieViewController.swift
//  SmileSelfie
//
//  Created by Wu on 2019/5/29.
//  Copyright © 2019 amG. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class SmileSelfieViewController: UIViewController {
    
    @IBOutlet var faceView: FaceView!
    
    let captureSession = AVCaptureSession()
    var sequenceHandler = VNSequenceRequestHandler()
    var previewLayer: AVCaptureVideoPreviewLayer!
    let dataOutputQueue = DispatchQueue(
        label: "video data queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
    
    let cameraOutput = CameraCaptureOutput()
    let completionImageView = UIImageView()
    var smileImage: UIImage? {
        didSet {
            if let image = smileImage {
                self.completionImageView.image = image
                self.view.addSubview(completionImageView)
                completionImageView.frame = self.view.frame
            } else {
                DispatchQueue.main.async {
                    self.completionImageView.image = nil
                    self.completionImageView.removeFromSuperview()
                }
            }
        }
    }
    
    //Button control feature
    var isLive: Bool = false
    var isFlash: Bool = false
    var isDrawFaceOutLine: Bool = false
    var isAuto: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        print(previewLayer.frame)
    }
    
    //MARK: Private
    private func setup() {
        configureCaptureSession()
        captureSession.startRunning()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
    }
    
    //MARK: IBAction
    @IBAction func liveButtonDidTouchupInside(_ sender: Any) {
        if (self.cameraOutput.cameraOutput.isLivePhotoCaptureSupported) {
            self.captureSession.beginConfiguration()
            self.cameraOutput.cameraOutput.isLivePhotoCaptureEnabled.toggle()
            self.captureSession.commitConfiguration()
        } else {
            print("Live Photo Not Supported")
        }
    }
    @IBAction func flashButtonDidTouchupInside(_ sender: Any) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
            else {return}
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if device.torchMode == AVCaptureDevice.TorchMode.on {
                    device.torchMode = AVCaptureDevice.TorchMode.off
                    //AVCaptureDevice.TorchModeAVCaptureDevice.TorchMode.off
                } else {
                    do {
                        try device.setTorchModeOn(level: 1.0)
                    } catch {
                        print(error)
                    }
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    @IBAction func modeButtonDidTouchupInside(_ sender: Any) {
        self.isDrawFaceOutLine.toggle()
    }
    @IBAction func collentionButtonDidTouchupInside(_ sender: Any) {
    }
    @IBAction func autoButtonDidTouchupInside(_ sender: Any) {
        self.isAuto.toggle()
    }
    @IBAction func countDownButtonDidTouchupInside(_ sender: Any) {
    }
    @IBAction func camChangeButtonDidTouchUpInside(_ sender: Any) {
        
        let session = self.captureSession
        session.beginConfiguration()
        
        //Remove existing input
        guard let currentCameraInput: AVCaptureInput = session.inputs.first else {
            return
        }
        
        session.removeInput(currentCameraInput)
        
        //Get new input
        var newCamera: AVCaptureDevice! = nil
        if let input = currentCameraInput as? AVCaptureDeviceInput {
            if (input.device.position == .back) {
                newCamera = cameraWithPosition(position: .front)
            } else {
                newCamera = cameraWithPosition(position: .back)
            }
        }
        
        //Add input to session
        var err: NSError?
        var newVideoInput: AVCaptureDeviceInput!
        do {
            newVideoInput = try AVCaptureDeviceInput(device: newCamera)
        } catch let err1 as NSError {
            err = err1
            newVideoInput = nil
        }
        
        if newVideoInput == nil || err != nil {
            print("Error creating capture device input: \(String(describing: err?.localizedDescription))")
        } else {
            session.addInput(newVideoInput)
        }
        
        //Commit all the configuration changes at once
        //Remove existing input
        for output in session.outputs {
            if output is AVCaptureVideoDataOutput {
                session.removeOutput(output)
                self.addFaceDetectOutput()
            }
        }
        
        session.commitConfiguration()
    }
    
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }

}


// MARK: - Video Processing methods

extension SmileSelfieViewController {
    func configureCaptureSession() {
        // Define the capture device we want to use
        guard
            let camera = cameraWithPosition(position: .front)
            else {
                fatalError("No front video camera available")
        }
        
        // Connect the camera to the capture session input
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            captureSession.addInput(cameraInput)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        //add out put
        self.addFaceDetectOutput()
        self.addCameraOutput()
        
        // Configure the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    func addFaceDetectOutput() {
        // Create the video data output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        // Add the video output to the capture session
        captureSession.addOutput(videoOutput)
        
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
    }
    
    func addCameraOutput() {
        self.cameraOutput.cameraOutput.isHighResolutionCaptureEnabled = true
        self.cameraOutput.cameraOutput.isLivePhotoCaptureEnabled = false
        self.captureSession.addOutput(self.cameraOutput.cameraOutput)
    }
}


// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension SmileSelfieViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // 2
        let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: self.detectedFace)
        
        // 3
        do {
            try sequenceHandler.perform(
                [detectFaceRequest],
                on: imageBuffer,
                orientation: .leftMirrored)
        } catch {
            print(error.localizedDescription)
        }
        
        //detect smile with ciimage
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let attachments:CFDictionary? = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate)
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer!, options: attachments as? [CIImageOption : Any])
        
        let detectorOptions = [CIDetectorAccuracy: CIDetectorAccuracyHigh] as [String : Any]
        let faceDetector:CIDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: detectorOptions)!
        
        let imageOptions: [String : Any] = [CIDetectorImageOrientation:1, CIDetectorSmile: true]
        let features = faceDetector.features(in: ciImage, options: imageOptions)
        
        if (features.count != 0) {
            for faceFeature in features {
                if let faceFeature = faceFeature as? CIFaceFeature {
                    if faceFeature.hasSmile {
                        if isAuto {
                            self.saveToCamera()
                        }
                    } else {
                        self.smileImage = nil
                    }
                }
            }
        }
        
    }
    
    func detectedFace(request: VNRequest, error: Error?) {
        
        if (!isDrawFaceOutLine) { faceView.clear(); return }
        
        guard
            let results = request.results as? [VNFaceObservation],
            let result = results.first
            else {
                faceView.clear()
                return
        }
        drawFaceDetectOutLine(for: result)
    }
    
    func convert(rect: CGRect) -> CGRect {
        // 1
        let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
        
        // 2
        let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
        
        // 3
        return CGRect(origin: origin, size: size.cgSize)
    }
    
    func landmark(point: CGPoint, to rect: CGRect) -> CGPoint {
        // 2
        let absolute = point.absolutePoint(in: rect)
        
        // 3
        let converted = previewLayer.layerPointConverted(fromCaptureDevicePoint: absolute)
        
        // 4
        return converted
    }
    
    func landmark(points: [CGPoint]?, to rect: CGRect) -> [CGPoint]? {
        return points?.compactMap { landmark(point: $0, to: rect) }
    }
    
    //face
    func drawFaceDetectOutLine(for result: VNFaceObservation) {
        defer {
            DispatchQueue.main.async {
                self.faceView.setNeedsDisplay()
            }
        }
        
        //red box
        let box = result.boundingBox
        //TODO: bug when changing session output
//        faceView.boundingBox = convert(rect: box)
        
        guard let landmarks = result.landmarks else {
            return
        }
        
        if let leftEye = landmark(
            points: landmarks.leftEye?.normalizedPoints,
            to: box) {
            faceView.leftEye = leftEye
        }
        
        if let rightEye = landmark(
            points: landmarks.rightEye?.normalizedPoints,
            to: box) {
            faceView.rightEye = rightEye
        }
        
        if let leftEyebrow = landmark(
            points: landmarks.leftEyebrow?.normalizedPoints,
            to: box) {
            faceView.leftEyebrow = leftEyebrow
        }
        
        if let rightEyebrow = landmark(
            points: landmarks.rightEyebrow?.normalizedPoints,
            to: box) {
            faceView.rightEyebrow = rightEyebrow
        }
        
        if let nose = landmark(
            points: landmarks.nose?.normalizedPoints,
            to: box) {
            faceView.nose = nose
        }
        
        if let outerLips = landmark(
            points: landmarks.outerLips?.normalizedPoints,
            to: box) {
            faceView.outerLips = outerLips
        }
        
        if let innerLips = landmark(
            points: landmarks.innerLips?.normalizedPoints,
            to: box) {
            faceView.innerLips = innerLips
        }
        
        if let faceContour = landmark(
            points: landmarks.faceContour?.normalizedPoints,
            to: box) {
            faceView.faceContour = faceContour
        }
    }
    
}

extension SmileSelfieViewController {
    
    func saveToCamera() {
        DispatchQueue.global(qos: .userInteractive).async {
            DispatchQueue.main.async {
                self.cameraOutput.captureCompletion = { (image) in
                    self.smileImage = image
                }
                self.cameraOutput.capturePhoto()
            }
        }
    }
}

