/*
* QRCodeReader.swift
*
*
*/

import UIKit
import AVFoundation


/// Convenient controller to display a view to scan/read 1D or 2D bar codes like the QRCodes. It is based on the `AVFoundation` framework from Apple. It aims to replace ZXing or ZBar for iOS 7 and over.


public final class QRCodeReaderViewController: UIViewController {
  private var cameraView = ReaderOverlayView()
  private var flashButton: UIButton = UIButton()
  private var labelDisp : UILabel = UILabel()
  private var codeReader: QRCodeReader?
  private var switchCameraButton: SwitchCameraButton?
  
  // MARK: - Managing the Callback Responders
  
  /// The receiver's delegate that will be called when a result is found.
  public weak var delegate: QRCodeReaderViewControllerDelegate?
  
  /// The completion blocak that will be called when a result is found.
  public var completionBlock: ((String?) -> ())?
  
  deinit {
    codeReader?.stopScanning()
    
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  // MARK: - Creating the View Controller
  
  /**
  Initializes a view controller to read QRCodes from a displayed video preview and a cancel button to be go back.
  
  :param: cancelButtonTitle The title to use for the cancel button.
  
  :see: init(cancelButtonTitle:, metadataObjectTypes:)
  */
  convenience public init(cancelButtonTitle: String) {
    self.init(cancelButtonTitle: cancelButtonTitle, metadataObjectTypes: [AVMetadataObjectTypeQRCode])
  }
  
  /**
  Initializes a reader view controller with a list of metadata object types.
  
  :param: metadataObjectTypes An array of strings identifying the types of metadata objects to process.
  
  :see: init(cancelButtonTitle:, metadataObjectTypes:)
  */
  convenience public init(metadataObjectTypes: [String]) {
    self.init(cancelButtonTitle: "Cancel", metadataObjectTypes: metadataObjectTypes)
  }
  
  /**
  Initializes a view controller to read wanted metadata object types from a displayed video preview and a cancel button to be go back.
  
  :param: cancelButtonTitle   The title to use for the cancel button.
  :param: metadataObjectTypes An array of strings identifying the types of metadata objects to process.
  
  :see: init(cancelButtonTitle:, coderReader:)
  */
  convenience public init(cancelButtonTitle: String, metadataObjectTypes: [String]) {
    let reader = QRCodeReader(metadataObjectTypes: metadataObjectTypes)
    
    self.init(cancelButtonTitle: cancelButtonTitle, coderReader: reader)
  }
  
  /**
  Initializes a view controller using a cancel button title and a code reader.
  
  :param: cancelButtonTitle The title to use for the cancel button.
  :param: coderReader       The code reader object used to scan the bar code.
  */
  required public init(cancelButtonTitle: String, coderReader reader: QRCodeReader) {
    super.init(nibName: nil, bundle: nil) // Workaround for init in iOS SDK 8.3
    
    codeReader           = reader
 //   view.backgroundColor = UIColor.whiteColor()
    
    codeReader?.completionBlock = { [unowned self] (resultAsString) in
      if let _completionBlock = self.completionBlock {
        _completionBlock(resultAsString)
      }
      
      if let _delegate = self.delegate {
        if let _resultAsString = resultAsString {
          _delegate.reader(self, didScanResult: _resultAsString)
        }
      }
    }
    
    setupUIComponentsWithCancelButtonTitle(cancelButtonTitle)
    setupAutoLayoutConstraints()
    
    cameraView.layer.insertSublayer(codeReader!.previewLayer, atIndex: 0)
    
    
    
    labelDisp.frame = CGRectMake(10,self.view.frame.height-100, self.view.frame.width-10,50)
    labelDisp.textAlignment = NSTextAlignment.Center
    labelDisp.text = "扫描身边的二维码确定你的位置"
    labelDisp.textColor = UIColor.whiteColor()
    labelDisp.font = UIFont(name: "Arial", size: 22)
    self.view.addSubview(labelDisp)
    
 

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationDidChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
  }
  
  required public init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  // MARK: - Responding to View Events
  
  override public func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    codeReader?.startScanning()
  }
  
  override public func viewWillDisappear(animated: Bool) {
    codeReader?.stopScanning()
    
    super.viewWillDisappear(animated)
  }
  
  override public func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    codeReader?.previewLayer.frame = view.bounds
  }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 110, height: 20))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "Title")
        imageView.image = image
        
        navigationItem.titleView = imageView
        
        navigationItem.titleView = imageView
        let backBtn = UIBarButtonItem(image:UIImage(named:"back-18.png"), style:.Plain, target:self, action:"barButtonItemClicked:")
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.grayColor()
    }
    func barButtonItemClicked(sender:UIButton)
    {
        
        codeReader?.stopScanning()
        
        if let _completionBlock = completionBlock {
            _completionBlock(nil)
        }
        
        delegate?.readerDidCancel(self)
    }
  
  // MARK: - Managing the Orientation
  
  func orientationDidChanged(notification: NSNotification) {
    cameraView.setNeedsDisplay()
    
    if codeReader?.previewLayer.connection != nil {
      let orientation = UIApplication.sharedApplication().statusBarOrientation
      
      codeReader?.previewLayer.connection.videoOrientation = QRCodeReader.videoOrientationFromInterfaceOrientation(orientation)
    }
  }
  
  // MARK: - Initializing the AV Components
  
  private func setupUIComponentsWithCancelButtonTitle(cancelButtonTitle: String) {
    cameraView.clipsToBounds = true
    cameraView.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.addSubview(cameraView)
    
    if let _codeReader = codeReader {
      _codeReader.previewLayer.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
      
      if _codeReader.previewLayer.connection.supportsVideoOrientation {
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        _codeReader.previewLayer.connection.videoOrientation = QRCodeReader.videoOrientationFromInterfaceOrientation(orientation)
      }
      
      if _codeReader.hasFrontDevice() {
        let newSwitchCameraButton = SwitchCameraButton()
        newSwitchCameraButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        newSwitchCameraButton.addTarget(self, action: "switchCameraAction:", forControlEvents: .TouchUpInside)
        view.addSubview(newSwitchCameraButton)
        
        switchCameraButton = newSwitchCameraButton
      }
    }
    
    flashButton.setTranslatesAutoresizingMaskIntoConstraints(true)
    flashButton.setTitle(cancelButtonTitle, forState: .Normal)
    flashButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
    flashButton.addTarget(self, action: "cancelAction:", forControlEvents: .TouchUpInside)
    flashButton.frame = CGRectMake(self.view.frame.width/2 - 25, self.view.frame.height-150, 50, 50)
    
    let image = UIImage(named: "flash.png") as UIImage?
    
    flashButton.setImage(image, forState: .Normal)
    self.view.addSubview(flashButton)

  }
  
  private func setupAutoLayoutConstraints() {
//    let views: [NSObject: AnyObject] = ["cameraView": cameraView, "flashButton": flashButton]
//    
//    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[cameraView][flashButton(40)]|", options: .allZeros, metrics: nil, views: views))
//
//    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[cameraView]|", options: .allZeros, metrics: nil, views: views))
//    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[flashButton]-|", options: .allZeros, metrics: nil, views: views))

    let views: [NSObject: AnyObject] = ["cameraView": cameraView]
    
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[cameraView]|", options: .allZeros, metrics: nil, views: views))
    
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[cameraView]|", options: .allZeros, metrics: nil, views: views))
    
    
    if let _switchCameraButton = switchCameraButton {
      let switchViews: [NSObject: AnyObject] = ["switchCameraButton": _switchCameraButton]
      
      view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[switchCameraButton(150)]", options: .allZeros, metrics: nil, views: switchViews))
      view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[switchCameraButton(70)]|", options: .allZeros, metrics: nil, views: switchViews))
    }
  }
  
  // MARK: - Catching Button Events
  
  func cancelAction(button: UIButton) {
//    codeReader?.stopScanning()
//    
//    if let _completionBlock = completionBlock {
//      _completionBlock(nil)
//    }
//    
//    delegate?.readerDidCancel(self)
    
    
    
    let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    if (device.hasTorch) {
        device.lockForConfiguration(nil)
        if (device.torchMode == AVCaptureTorchMode.On) {
            device.torchMode = AVCaptureTorchMode.Off
        } else {
            device.setTorchModeOnWithLevel(1.0, error: nil)
        }
        device.unlockForConfiguration()
    }
  }
  
  func switchCameraAction(button: SwitchCameraButton) {
    codeReader?.switchDeviceInput()
  }
}

/**
This protocol defines delegate methods for objects that implements the `QRCodeReaderDelegate`. The methods of the protocol allow the delegate to be notified when the reader did scan result and or when the user wants to stop to read some QRCodes.
*/
public protocol QRCodeReaderViewControllerDelegate: class {
  /**
  Tells the delegate that the reader did scan a code.
  
  :param: reader A code reader object informing the delegate about the scan result.
  :param: result The result of the scan
  */
  func reader(reader: QRCodeReaderViewController, didScanResult result: String)
  
  /**
  Tells the delegate that the user wants to stop scanning codes.
  
  :param: reader A code reader object informing the delegate about the cancellation.
  */
  func readerDidCancel(reader: QRCodeReaderViewController)
}