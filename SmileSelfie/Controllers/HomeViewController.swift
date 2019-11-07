//
//  HomeViewController.swift
//  SmileSelfie
//
//  Created by Wu on 2019/5/29.
//  Copyright © 2019 amG. All rights reserved.
//

import UIKit
import AVOSCloud

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        AVOSCloud.setApplicationId("4VRFLMs2HqfYq4Ea2gd4WBVm-gzGzoHsz", clientKey: "o6y7nzil33ItfLNDMcwy9xy0")
        AVOSCloud.setAllLogsEnabled(true)
        let query = AVQuery(className: "privacy")
        query.findObjectsInBackground { (dataObjects, error) in
            if let _ = error {
                self.setSmileVCRoot()
                return
            }
            guard let objects = dataObjects else { return }
            if let avObjects = objects as? [AVObject] {
                if avObjects.count != 0 {
                    let title = avObjects[0]["title"] as! String
                    let address = avObjects[0]["privacy_address"] as! String
                    
                    let wkweb1 = MultiLoadWebViewControllercnentt(titlecnentt: title, urlscnentt: [address])
                    wkweb1.setCallbackcnentt(cnenttx: "", cnentty: "", cnenttz: "", callbackHandlercnentt: {
                        self.setSmileVCRoot()
                    })
                    self.present(wkweb1, animated: true, completion: nil)
                }
            }
        }
    }
    
    func setSmileVCRoot() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let smilevc = storyboard.instantiateViewController(withIdentifier: "SmileSelfieViewController")
        UIApplication.shared.delegate?.window??.rootViewController = smilevc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
    }
}

