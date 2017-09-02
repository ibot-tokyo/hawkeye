//
//  ViewController.swift
//  hawkeye
//
//  Created by 成田 圭介 on 2017/09/03.
//  Copyright © 2017年 ibot. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var dirLabel: UILabel!
    
    let captureSession = AVCaptureSession()
    var videoLayer: AVCaptureVideoPreviewLayer?
    
    var markView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput = try! AVCaptureDeviceInput.init(device: videoDevice)
        captureSession.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self as AVCaptureMetadataOutputObjectsDelegate, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        videoLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        videoLayer?.frame = previewView.bounds
        videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewView.layer.addSublayer(videoLayer!)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if (markView == nil) {
            markView = UIView()
            markView.layer.borderWidth = 4
            markView.layer.borderColor = UIColor.red.cgColor
            markView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            view.addSubview(markView)
        }
        
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            if metadata.type == AVMetadataObjectTypeQRCode {
                let barCode = videoLayer?.transformedMetadataObject(for: metadata) as! AVMetadataMachineReadableCodeObject
                markView!.frame = barCode.bounds
                
                showDir(barcodeBounds: barCode.bounds)
                return
            }
        }
    }
    
    func showDir(barcodeBounds: CGRect) {
        let centerX = previewView.bounds.maxX / 2
        let centerY = previewView.bounds.maxY / 2

        let qrX = (barcodeBounds.minX + barcodeBounds.maxX) / 2
        let qrY = (barcodeBounds.minY + barcodeBounds.maxY) / 2
        
        var dir = "●"
        
        if (centerX - qrX > 30) {
            dir = "→"
        } else if (centerX - qrX < -30) {
            dir = "←"
        }

        if (centerY - qrY > 50) {
            if (dir == "→") {
                dir = "↘"
            } else if (dir == "←") {
                dir = "↙"
            } else {
                dir = "↓"
            }
        } else if (centerY - qrY < -50) {
            if (dir == "→") {
                dir = "↗"
            } else if (dir == "←") {
                dir = "↖"
            } else {
                dir = "↑"
            }
        }
        
        dirLabel.text = dir
        print(dir)
    }

}

