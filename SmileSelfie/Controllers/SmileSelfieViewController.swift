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
import YPImagePicker
import AwesomeIntroGuideView
import Masonry
import DWAnimatedLabel
import AVOSCloud

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
    @IBOutlet weak var smilingImageView: UIImageView!
    @IBOutlet weak var smilingCountDownLabel: UILabel!
    
    //capture session
    let captureSession = AVCaptureSession()
    var sequenceHandler = VNSequenceRequestHandler()
    var previewLayer: AVCaptureVideoPreviewLayer!
    let dataOutputQueue = DispatchQueue(
        label: "video data queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
    var cameraInput: AVCaptureDeviceInput!
    var audioInput: AVCaptureInput? = nil
    let cameraOutput = CameraCaptureOutput()
    let videoOutput = AVCaptureVideoDataOutput()
    
    //smile
    var smileImage: UIImage? {
        didSet {
            guard
                let image = smileImage
            else
                { return }
            self.savePhotoAnimation(with: image)
        }
    }
    var isSmiling: Bool = false {
        didSet {
            self.configAutoSavingPhoto(with: isSmiling)
            if isSmiling {
                DispatchQueue.main.async {
                    self.smilingImageView.tintColor = UIColor(red: 255/255, green: 126/255, blue: 121/255, alpha: 1.0)
                }
            } else {
                DispatchQueue.main.async {
                    self.smilingImageView.tintColor = .clear
                }
            }
        }
    }
    var isAutoSavingPhoto: Bool = false
    var smileTimeInterval: Int = 66666
    var timer: DispatchSourceTimer? = nil
    var timerTimeInterval: Int = 66666

    //button control feature
    var flashState: AVCaptureDevice.FlashMode = .off {
        didSet {
            switch self.flashState {
            case .off:
                self.flashButton.setImage(UIImage(named: "flash_off"), for: .normal)
                break
            case .auto:
                self.flashButton.setImage(UIImage(named: "flash_auto"), for: .normal)
                break
            case .on:
                self.flashButton.setImage(UIImage(named: "flash_on"), for: .normal)
                break
            @unknown default:
                self.flashButton.setImage(UIImage(named: "flash_off"), for: .normal)
            }
        }
    }
    var isDrawFaceOutLine: Bool = false
    var isAuto: Bool = false
    
    //guide
    var coachMarksView: AwesomeIntroGuideView = AwesomeIntroGuideView()
    var guideViewArr: [UIView] = []
    var firstGuideLabel: DWAnimatedLabel = DWAnimatedLabel(frame: CGRect(x: 0, y: UIScreen.main.bounds.height/2 - 25, width: UIScreen.main.bounds.size.width, height: 50))
    var dwAnimatedLabel_1: DWAnimatedLabel = DWAnimatedLabel(frame: CGRect(x: 20, y: 44, width: UIScreen.main.bounds.size.width, height: 150))
    var dwAnimatedLabel_2: DWAnimatedLabel = DWAnimatedLabel(frame: CGRect(x: 20, y: 44, width: UIScreen.main.bounds.size.width, height: 150))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (UserDefaults.standard.value(forKey: "first_time_open_app") == nil) {
            UserDefaults.standard.setValue(true, forKey: "first_time_open_app")
            DispatchQueue.main.async {
                self.displayCoachView()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
    
    let items: [(icon: String, title: String, countDown: Int)] = [
        ("", "1s", 1),
        ("", "3s", 3),
        ("manual", "", 666666666666666666),
        ("", "5s", 5),
        ("", "10s", 10),
    ]
    
    private func setup() {
        configureCaptureSession()
        captureSession.startRunning()
        self.manualShotButton.imageView?.contentMode = .scaleAspectFit
        self.manualShotButton.contentVerticalAlignment = .fill
        self.manualShotButton.contentHorizontalAlignment = .fill
        
        //ui
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.smilingImageView.tintColor = .clear
        self.smilingCountDownLabel.text = ""
        
        self.coachMarksView = self.createGuideView()
    }
    
    private func displayCoachView() {
        self.view.addSubview(self.coachMarksView)
        
        //first guide label
        self.firstGuideLabel.textColor = .hexColor(with: "28D8B8")
        self.firstGuideLabel.textAlignment = .center
        self.firstGuideLabel.animationType = .typewriter
        self.firstGuideLabel.placeHolderColor = .blue
        self.firstGuideLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        self.view.addSubview(self.firstGuideLabel)
        self.firstGuideLabel.mas_makeConstraints({ (mask) in
            _ = mask?.centerX.equalTo()(self.view)
            _ = mask?.centerY.equalTo()(self.view)
            _ = mask?.leading.equalTo()(self.view)?.offset()(16)
            _ = mask?.trailing.equalTo()(self.view)?.offset()(-16)
        })
        self.firstGuideLabel.text = "Guide Start!"
        self.firstGuideLabel.startAnimation(duration: 2, nil)
        
        self.guideViewArr.append(self.firstGuideLabel)
        self.guideViewArr.append(self.timeIntervalCircleMenuButton)
        self.guideViewArr.append(self.flashButton)
        self.guideViewArr.append(self.modeButton)
        self.guideViewArr.append(self.liveButton)
        self.guideViewArr.append(self.collectionButton)
        self.guideViewArr.append(self.camChangeButton)
        self.guideViewArr.append(self.manualShotButton)
        self.coachMarksView.loadMarks(self.guideViewArr)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.coachMarksView.start()
        })
        self.collectionButton.isUserInteractionEnabled = false
        self.manualShotButton.isUserInteractionEnabled = false
    }
    
    private func createGuideView() -> AwesomeIntroGuideView {
        let guideView = AwesomeIntroGuideView(frame: UIScreen.main.bounds)
        guideView.insetSpacing = -8
        guideView.isEnableSkipButton = true
        guideView.isEnableContinueLabel = false
        guideView.animationDuration = 0.5
        guideView.guideShape = .square
        guideView.frame = CGRect(origin: self.view.center, size: CGSize.zero)
        guideView.frame = UIScreen.main.bounds
        
        //text guide
        self.dwAnimatedLabel_1.textColor = .white
        self.dwAnimatedLabel_1.animationType = .typewriter
        self.dwAnimatedLabel_1.placeHolderColor = .blue
        self.dwAnimatedLabel_1.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        guideView.addSubview(self.dwAnimatedLabel_1)
        self.dwAnimatedLabel_1.mas_makeConstraints({ (mask) in
            _ = mask?.centerX.equalTo()(guideView)
            _ = mask?.centerY.equalTo()(guideView)
            _ = mask?.leading.equalTo()(guideView)?.offset()(16)
            _ = mask?.trailing.equalTo()(guideView)?.offset()(-16)
        })
        self.dwAnimatedLabel_2.textColor = .white
        self.dwAnimatedLabel_2.animationType = .typewriter
        self.dwAnimatedLabel_2.placeHolderColor = .blue
        self.dwAnimatedLabel_2.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        guideView.addSubview(self.dwAnimatedLabel_2)
        self.dwAnimatedLabel_2.mas_makeConstraints({ (mask) in
            _ = mask?.top.equalTo()(self.dwAnimatedLabel_1.mas_bottom)
            _ = mask?.leading.equalTo()(guideView)?.offset()(16)
            _ = mask?.trailing.equalTo()(guideView)?.offset()(-16)
        })
        guideView.completionBlock = { guideView in
            self.collectionButton.isUserInteractionEnabled = true
            self.manualShotButton.isUserInteractionEnabled = true
        }
        guideView.willCompletionBlock = { guideView in
            self.firstGuideLabel.removeFromSuperview()
            let startLabel = DWAnimatedLabel(frame: CGRect(x: 20, y: 44, width: UIScreen.main.bounds.size.width, height: 150))
            startLabel.textColor = .hexColor(with: "F1C40F")
            startLabel.textAlignment = .center
            startLabel.animationType = .typewriter
            startLabel.placeHolderColor = .blue
            startLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            self.view.addSubview(startLabel)
            startLabel.mas_makeConstraints({ (mask) in
                _ = mask?.centerX.equalTo()(self.view)
                _ = mask?.centerY.equalTo()(self.view)
                _ = mask?.leading.equalTo()(self.view)?.offset()(16)
                _ = mask?.trailing.equalTo()(self.view)?.offset()(-16)
            })
            startLabel.text = "Start Using Smile Selfie!"
            startLabel.startAnimation(duration: 2, {
                UIView.animate(withDuration: 1.5, animations: {
                    startLabel.alpha = 0
                }, completion: { completion in
                    startLabel.removeFromSuperview()
                })
            })
        }
        guideView.willNavgateBlock = { (guideView, index) in
            print("will nav")
            if (index == 0) {
                guideView.guideShape = .circle
            } else if (index == 1) {
                self.firstGuideLabel.removeFromSuperview()
            }
            guideView.isUserInteractionEnabled = false
        }
        guideView.didNavgateBlock = { (guideView, index) in
            guideView.isUserInteractionEnabled = true
            print("did nav")
            if (index == 1) {
                guideView.isUserInteractionEnabled = false
                self.dwAnimatedLabel_1.text = "This is a manual/auto button."
                self.dwAnimatedLabel_1.startAnimation(duration: 3, {
                    self.dwAnimatedLabel_2.text = "Which decides if Auto capture smile."
                    self.dwAnimatedLabel_2.startAnimation(duration: 3, {
                        guideView.isUserInteractionEnabled = true
                    })
                })
            } else if (index == 2) {
                guideView.isUserInteractionEnabled = false
                self.dwAnimatedLabel_1.text = "Control Flash Light."
                self.dwAnimatedLabel_1.startAnimation(duration: 3, {
                    guideView.isUserInteractionEnabled = true
                })
                self.dwAnimatedLabel_2.text = " "
                self.dwAnimatedLabel_2.startAnimation(duration: 0.1, nil)
            } else if (index == 3) {
                guideView.isUserInteractionEnabled = false
                self.dwAnimatedLabel_1.text = "Normal/Outline mode for u."
                self.dwAnimatedLabel_1.startAnimation(duration: 3, {
                    guideView.isUserInteractionEnabled = true
                })
            } else if (index == 4) {
                guideView.isUserInteractionEnabled = false
                self.dwAnimatedLabel_1.text = "U can take live photo."
                self.dwAnimatedLabel_1.startAnimation(duration: 3, {
                    self.dwAnimatedLabel_2.text = "Make ur smile lively beauty."
                    self.dwAnimatedLabel_2.startAnimation(duration: 3, {
                        guideView.isUserInteractionEnabled = true
                    })
                })
            } else if (index == 5) {
                guideView.isUserInteractionEnabled = false
                self.dwAnimatedLabel_1.text = "This is gallery contains kinds filter."
                self.dwAnimatedLabel_1.startAnimation(duration: 3, {
                    guideView.isUserInteractionEnabled = true
                })
                self.dwAnimatedLabel_2.text = " "
                self.dwAnimatedLabel_2.startAnimation(duration: 0.1, nil)
            } else if (index == 6) {
                guideView.isUserInteractionEnabled = false
                self.dwAnimatedLabel_1.text = "Change ur camera."
                self.dwAnimatedLabel_2.text = " "
                self.dwAnimatedLabel_2.startAnimation(duration: 0.1, nil)
                self.dwAnimatedLabel_1.startAnimation(duration: 2, {
                    self.dwAnimatedLabel_2.text = "If u need."
                    self.dwAnimatedLabel_2.startAnimation(duration: 2, {
                        guideView.isUserInteractionEnabled = true
                    })
                })
            } else if (index == 7) {
                guideView.isUserInteractionEnabled = false
                self.dwAnimatedLabel_1.text = "U can also take a photo by ur own."
                self.dwAnimatedLabel_1.startAnimation(duration: 3.5, {
                    guideView.isUserInteractionEnabled = true
                })
                self.dwAnimatedLabel_2.text = " "
                self.dwAnimatedLabel_2.startAnimation(duration: 0.1, nil)
            }
        }
        guideView.loadType = .introLoad_Sync
        return guideView
    }
    
    //MARK: IBActions
    @IBAction func liveButtonDidTouchupInside(_ sender: UIButton) {
        if (self.cameraOutput.cameraOutput.isLivePhotoCaptureSupported) {
            self.liveButton.isSelected.toggle()
            self.cameraOutput.cameraOutput.isLivePhotoCaptureEnabled.toggle()
            
            //config camera output
            self.captureSession.beginConfiguration()
            self.configureAudioInput()
            self.captureSession.commitConfiguration()
            
        } else {
            print("Live Photo Not Supported")
        }
    }
    
    @IBAction func flashButtonDidTouchupInside(_ sender: UIButton) {
        switch self.flashState {
        case .off:
            self.flashState = .auto
            break
            
        case .auto:
            self.flashState = .on
            break
            
        case .on:
            self.flashState = .off
            break
            
        @unknown default:
            self.flashState = .off
            break
        }
        self.cameraOutput.flashMode = self.flashState
    }
    
    @IBAction func modeButtonDidTouchupInside(_ sender: Any) {
        self.isDrawFaceOutLine.toggle()
        self.modeButton.isSelected.toggle()
    }
    
    @IBAction func collentionButtonDidTouchupInside(_ sender: Any) {
       self.presentImagePicker()
    }
    
    @IBAction func manualShotButtonDidTouchUpInside(_ sender: UIButton) {
        self.saveToCamera()
    }
    
    @IBAction func camChangeButtonDidTouchUpInside(_ sender: Any) {
        self.camChangeButton.isSelected.toggle()
        self.changeCamera()
    }
}

//MARK: Private Method
extension SmileSelfieViewController {
    func savePhotoAnimation(with image: UIImage) {
        let completionImageView = UIImageView()
        completionImageView.image = image
        completionImageView.contentMode = .scaleAspectFill
        self.view.addSubview(completionImageView)
        completionImageView.frame = self.view.frame
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            completionImageView.layer.cornerRadius = 5
            completionImageView.layer.masksToBounds = true
            completionImageView.layer.borderColor = UIColor.hexColor(with: "28D8B8").cgColor
            completionImageView.frame = CGRect.zero
            //                completionImageView.center = self.collectionButton.center
            completionImageView.frame = self.collectionButton.frame
        }) { (completion) in
            completionImageView.frame = self.collectionButton.frame
            completionImageView.layer.borderWidth = 0.5
        }
    }
    
    func presentImagePicker() {
        var config = YPImagePickerConfiguration()
        config.isScrollToChangeModesEnabled = true
        config.onlySquareImagesFromCamera = true
        config.usesFrontCamera = false
        config.showsFilters = true
        config.shouldSaveNewPicturesToAlbum = true
        config.albumName = "Smile Selfie Fliter"
        config.startOnScreen = YPPickerScreen.library
        config.screens = [.library]
        config.targetImageSize = YPImageSize.original
        config.overlayView = UIView()
        config.hidesStatusBar = true
        config.hidesBottomBar = true
        config.preferredStatusBarStyle = UIStatusBarStyle.default
        config.bottomMenuItemSelectedColour = UIColor.hexColor(with: "28D8B8")
        config.bottomMenuItemUnSelectedColour = UIColor.hexColor(with: "F1C40F")
        
        config.library.options = nil
        config.library.onlySquare = false
        config.library.minWidthForItem = nil
        config.library.mediaType = YPlibraryMediaType.photo
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 4
        config.library.spacingBetweenItems = 1.0
        config.library.skipSelectionsGallery = false
        
        YPImagePickerConfiguration.shared = config
        
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                picker.dismiss(animated: true, completion: {
                    self.savePhotoAnimation(with: photo.image)
                })
            } else {
                picker.dismiss(animated: true, completion: nil)
            }
            
        }
        present(picker, animated: true, completion: nil)
    }
}


// MARK: Capture session config for input & output

extension SmileSelfieViewController {
    
    private func configureCaptureSession() {
        
        captureSession.sessionPreset = .photo
       
        //add input
        self.addCameraInput()
        self.configureAudioInput()
        
        //add output
        self.addFaceDetectOutput()
        self.addCameraOutput()
        
        //configure the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    private func addCameraInput() {
        guard
            let camera = cameraWithPosition(position: .front)
            else {
                fatalError("No front video camera available")
        }
        
        do {
            self.cameraInput = try AVCaptureDeviceInput(device: camera)
            captureSession.addInput(self.cameraInput)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func changeCamera() {
        let session = self.captureSession
        session.beginConfiguration()
        
        //Get new input
        var newCamera: AVCaptureDevice! = nil
        if (self.cameraInput.device.position == .back) {
            newCamera = cameraWithPosition(position: .front)
        } else {
            newCamera = cameraWithPosition(position: .back)
        }
        
        //Remove & Add input to session
        do {
            session.removeInput(self.cameraInput)
            self.cameraInput = try AVCaptureDeviceInput(device: newCamera)
            session.addInput(self.cameraInput)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
        self.configureAudioInput()
        self.cameraOutput.cameraOutput.isLivePhotoCaptureEnabled = self.liveButton.isSelected
        session.commitConfiguration()
        
        guard let cameraInput = self.captureSession.inputs.first as? AVCaptureDeviceInput  else {
            return
        }
        self.cameraOutput.currentDevicePosition = cameraInput.device.position
        previewLayer.videoGravity = .resizeAspectFill
        
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
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
    
    private func configureAudioInput() {
        if self.cameraOutput.cameraOutput.isLivePhotoCaptureEnabled {
            guard
                let audioDevice = AVCaptureDevice.default(for: .audio),
                let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice),
                self.captureSession.canAddInput(audioDeviceInput)
                else { return }
            self.audioInput = audioDeviceInput
            self.captureSession.addInput(audioDeviceInput)
        } else {
            guard
                let audioInput = self.audioInput
                else { return }
            self.captureSession.removeInput(audioInput)
        }
    }
    
    private func addFaceDetectOutput() {
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        captureSession.addOutput(videoOutput)
        
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
    }
    
    private func addCameraOutput() {
        self.cameraOutput.cameraOutput.isHighResolutionCaptureEnabled = true
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
        
        guard
            let results = request.results as? [VNFaceObservation],
            let result = results.first
            else {
                faceView.clear()
                self.isSmiling = false
                return
        }
        if (!isDrawFaceOutLine) {
            faceView.clear()
            return
        } else {
            drawFaceDetectOutLine(for: result)
        }
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
        if !isAuto || !isSmiling {
            self.cancelSmileTimer()
            return
        }
        
        //auto saving
        if (self.isAutoSavingPhoto == false) {
            //TODO: cancel when changing to manual
            if (self.timer == nil) {
                
                self.isAutoSavingPhoto = true
                
                self.timerTimeInterval = self.smileTimeInterval
                
                self.timer = DispatchSource.makeTimerSource()
                
                self.timer?.schedule(deadline: .now(), repeating: .seconds(1))
                
                self.timer?.setEventHandler { [weak self] in
                    self?.updateCounter()
                }
                
                self.timer?.resume()
            }
        }
    }
    
    @objc func updateCounter() {
        let displayText = "\(self.timerTimeInterval/1)"
        DispatchQueue.main.async {
            self.smilingCountDownLabel.text = displayText
        }
        if self.timerTimeInterval > 0 {
            //update counter
            self.timerTimeInterval -= 1
        } else if self.timerTimeInterval == 0 {
             //save photo
            if !self.isSmiling || !self.isAuto {
                self.isAutoSavingPhoto = false
                return
            }
            self.saveToCamera()
            self.cancelSmileTimer()
        }
    }
    
    private func cancelSmileTimer() {
        self.isAutoSavingPhoto = false
        if let timer = self.timer {
            timer.cancel()
            self.timer = nil
        }
        DispatchQueue.main.async {
            self.smilingCountDownLabel.text = ""
            self.smilingImageView.tintColor = .clear
        }
    }
    
    private func saveToCamera() {
        DispatchQueue.main.async {
            self.cameraOutput.captureCompletion = { (image) in
                self.smileImage = image
                if (!self.cameraOutput.cameraOutput.isLivePhotoCaptureEnabled) {
                    UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
            self.cameraOutput.capturePhoto()
        }
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        print("saved photo")
        if let error = error {
            let ac = UIAlertController(title: "Save Photo Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

//CircleMenuDelegate
extension SmileSelfieViewController {
    
    func menuOpened(_ circleMenu: CircleMenu) {
        self.isAuto = false
    }
    
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        
        button.backgroundColor = .clear
        button.setTitle(items[atIndex].title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        if (atIndex == 2) {
            button.setImage(UIImage(named: items[atIndex].icon), for: .normal)
            button.imageEdgeInsets = self.timeIntervalCircleMenuButton.imageEdgeInsets
        }
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
        self.smileTimeInterval = self.items[atIndex].countDown
    }
}

