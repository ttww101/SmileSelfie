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
import CircleMenu

class SmileSelfieViewController: UIViewController, CircleMenuDelegate {
    
    
    //UI
    @IBOutlet var faceView: FaceView!
    @IBOutlet var collectionButton: UIButton!
    @IBOutlet var liveButton: UIButton!
    @IBOutlet var flashButton: UIButton!
    @IBOutlet var modeButton: UIButton!
    @IBOutlet var camChangeButton: UIButton!
    @IBOutlet var manualShotButton: UIButton!
    @IBOutlet weak var timeIntervalCircleMenuButton: CircleMenu!
    
    //capture session
    let captureSession = AVCaptureSession()
    var sequenceHandler = VNSequenceRequestHandler()
    var previewLayer: AVCaptureVideoPreviewLayer!
    let dataOutputQueue = DispatchQueue(
        label: "video data queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
    let cameraOutput = CameraCaptureOutput()
    
    //smile
    var smileImage: UIImage? {
        didSet {
            guard
                let image = smileImage
            else
                { return }
            
            //image animation
            let completionImageView = UIImageView()
            completionImageView.image = image
            completionImageView.contentMode = .scaleAspectFill
            self.view.addSubview(completionImageView)
            completionImageView.frame = self.view.frame
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
                completionImageView.layer.cornerRadius = 5
                completionImageView.layer.masksToBounds = true
                completionImageView.layer.borderColor = UIColor.hexColor(with: "28D8B8").cgColor
                completionImageView.frame = self.collectionButton.frame
            }) { (completion) in
                completionImageView.layer.borderWidth = 0.5
                print("end")
            }
        }
    }
    var isSmiling: Bool = false {
        didSet {
            self.configAutoSavingPhoto(with: isSmiling)
        }
    }
    var isAutoSavingPhoto: Bool = false
    var smileTimeInterval: TimeInterval = 3
    
    //imagePicker
    var imagePicker: UIImagePickerController!
    
    //button control feature
    var isLive: Bool = false
    var isFlash: Bool = false
    var isDrawFaceOutLine: Bool = false
    var isAuto: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
    
    let items: [(icon: String, color: UIColor, title: String)] = [
        ("", UIColor.clear, "1s"),
        ("", UIColor.clear, "3s"),
        ("manual", UIColor.clear, ""),
        ("", UIColor.clear, "10s"),
        ("", UIColor.clear, "15s"),
    ]
    
    private func setup() {
        configureCaptureSession()
        captureSession.startRunning()
        self.manualShotButton.imageView?.contentMode = .scaleAspectFit
        self.manualShotButton.contentVerticalAlignment = .fill
        self.manualShotButton.contentHorizontalAlignment = .fill
        
        self.timeIntervalCircleMenuButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 10, right: 12)
        
        //ui
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
    }
    
    //MARK: IBActions
    @IBAction func liveButtonDidTouchupInside(_ sender: Any) {
        self.liveButton.isSelected.toggle()
        if (self.cameraOutput.cameraOutput.isLivePhotoCaptureSupported) {
            self.captureSession.beginConfiguration()
            self.cameraOutput.cameraOutput.isLivePhotoCaptureEnabled.toggle()
            self.captureSession.commitConfiguration()
        } else {
            print("Live Photo Not Supported")
        }
    }
    
    @IBAction func flashButtonDidTouchupInside(_ sender: UIButton) {
        self.flashButton.isSelected.toggle()
        if sender.isSelected {
            self.cameraOutput.flashMode = .on
        } else {
            self.cameraOutput.flashMode = .off
        }
    }
    
    @IBAction func modeButtonDidTouchupInside(_ sender: Any) {
        self.isDrawFaceOutLine.toggle()
        self.modeButton.isSelected.toggle()
    }
    
    @IBAction func collentionButtonDidTouchupInside(_ sender: Any) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func manualShotButtonDidTouchUpInside(_ sender: UIButton) {
        self.saveToCamera()
    }
    
    @IBAction func camChangeButtonDidTouchUpInside(_ sender: Any) {
        self.camChangeButton.isSelected.toggle()
        self.changeCamera()
    }
}


// MARK: Capture session config for input & output

extension SmileSelfieViewController {
    
    private func configureCaptureSession() {
        
        captureSession.sessionPreset = .photo
        
        guard
            let camera = cameraWithPosition(position: .front)
            else {
                fatalError("No front video camera available")
        }
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            captureSession.addInput(cameraInput)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        //add out put
        self.addFaceDetectOutput()
        self.addCameraOutput()
        
        //configure the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    private func addFaceDetectOutput() {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        captureSession.addOutput(videoOutput)
        
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
    }
    
    private func addCameraOutput() {
        self.cameraOutput.cameraOutput.isHighResolutionCaptureEnabled = true
        self.cameraOutput.cameraOutput.isLivePhotoCaptureEnabled = false
        self.captureSession.addOutput(self.cameraOutput.cameraOutput)
    }
}


// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension SmileSelfieViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        //face
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: self.detectedFace)
        
        do {
            try sequenceHandler.perform(
                [detectFaceRequest],
                on: imageBuffer,
                orientation: .leftMirrored)
        } catch {
            print(error.localizedDescription)
        }
        
        //smile
        self.detectedSmile(with: sampleBuffer)
    }
    
    private func detectedFace(request: VNRequest, error: Error?) {
        
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
    
    private func detectedSmile(with sampleBuffer: CMSampleBuffer) {
        
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
                    self.isSmiling = faceFeature.hasSmile
                }
            }
        }
    }
}

//draw face
extension SmileSelfieViewController {
    
    private func drawFaceDetectOutLine(for result: VNFaceObservation) {
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
    
    private func convert(rect: CGRect) -> CGRect {
        
        let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
        
        let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
        
        return CGRect(origin: origin, size: size.cgSize)
    }
    
    private func landmark(points: [CGPoint]?, to rect: CGRect) -> [CGPoint]? {
        return points?.compactMap { landmark(point: $0, to: rect) }
    }
    
    private func landmark(point: CGPoint, to rect: CGRect) -> CGPoint {
        // 2
        let absolute = point.absolutePoint(in: rect)
        
        // 3
        let converted = previewLayer.layerPointConverted(fromCaptureDevicePoint: absolute)
        
        // 4
        return converted
    }
    
}

//camera method
extension SmileSelfieViewController {
    
    private func configAutoSavingPhoto(with isSmiling: Bool) {
        if !isAuto { return }
        if !isSmiling { return }
        
        //auto saving
        if (self.isAutoSavingPhoto == false) {
            self.isAutoSavingPhoto = true
            //TODO: cancel when changing auto
            DispatchQueue.main.asyncAfter(deadline: .now() + smileTimeInterval, execute: {
                if !self.isSmiling || !self.isAuto {
                    self.isAutoSavingPhoto = false
                    return
                }
                self.saveToCamera()
                self.isAutoSavingPhoto = false
            })
        }
    }
    
    private func saveToCamera() {
        DispatchQueue.main.async {
            self.cameraOutput.captureCompletion = { (image) in
                self.smileImage = image
                UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
            self.cameraOutput.capturePhoto()
        }
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save Photo Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    private func changeCamera() {
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
    
    private func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
}

//CircleMenuDelegate
extension SmileSelfieViewController {
    
    func menuOpened(_ circleMenu: CircleMenu) {
        self.isAuto = false
    }
    
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        
        button.backgroundColor = items[atIndex].color
        button.setTitle(items[atIndex].title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        if (atIndex == 2) {
            button.setImage(UIImage(named: items[atIndex].icon), for: .normal)
            button.imageEdgeInsets = self.timeIntervalCircleMenuButton.imageEdgeInsets
        }
        
        // set highlited image
//        let highlightedImage = UIImage(named: items[atIndex].icon)?.withRenderingMode(.alwaysTemplate)
//        button.setImage(highlightedImage, for: .highlighted)
//        button.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
//        button.imageView?.contentMode = .scaleAspectFit
    }
    
    func circleMenu(_: CircleMenu, buttonWillSelected _: UIButton, atIndex: Int) {
        if (atIndex != 2) {
            self.timeIntervalCircleMenuButton.isSelected = true
            self.isAuto = true
        } else {
            self.timeIntervalCircleMenuButton.isSelected = false
            self.isAuto = false
        }
    }
    
    func circleMenu(_: CircleMenu, buttonDidSelected _: UIButton, atIndex: Int) {
        switch atIndex {
        case 0:
            self.smileTimeInterval = 1
            break
            
        case 1:
            self.smileTimeInterval = 3
            break
            
        case 2:
            break
            
        case 3:
            self.smileTimeInterval = 10
            break
            
        case 4:
            self.smileTimeInterval = 15
            break
            
        default: break
        }
    }
}

extension SmileSelfieViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
//        imageTake.image = selectedImage
    }
}
