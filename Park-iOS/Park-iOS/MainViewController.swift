//
//  MainViewController.swift
//  Park_iOS
//
//  Created by Shaohua chen on 5/4/15.
//  Copyright (c) 2015 Shaohua chen. All rights reserved.
//
import UIKit
import WebKit
import CoreMotion

protocol MainViewControllerDelegate{
    func didFinishMakeVC(controller:MainViewController)
}
class MainViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate  {
    
    @IBOutlet var containerView : UIView! = nil
    
    @IBOutlet weak var rotateButton: UIImageView!
    var webView: WKWebView?
    
    var mPoint:String?
    var mCurrent:String?
    var mPark:String?
    var mState : Int = 0
    
    var delegate:MainViewControllerDelegate! = nil
    
    let motionManager: CMMotionManager = CMMotionManager()
    var mCurrentDegree:CGFloat = 0.0
    var isRotate : Bool = false
    
    override func loadView() {
        super.loadView()
        
        var contentController = WKUserContentController();
        var userScript = WKUserScript(
            source: "redHeader()",
            injectionTime: WKUserScriptInjectionTime.AtDocumentEnd,
            forMainFrameOnly: true
        )
        contentController.addUserScript(userScript)
        contentController.addScriptMessageHandler(
            self,
            name: "callbackHandler"
        )
        
        var config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        //self.webView = WKWebView(frame: self.view.frame, configuration: config)
        
        self.webView = WKWebView(frame:CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 60), configuration: config)
        
        mPark = g_Park
        mState = 2
        
        mCurrent = g_Current
        
        self.webView?.navigationDelegate = self
        //self.view = self.webView!
        self.view.addSubview(self.webView!)
        
        
        // Initialize MotionManager
        motionManager.deviceMotionUpdateInterval = 0.05 // 20Hz
        
        // Start motion data acquisition
        motionManager.startDeviceMotionUpdatesToQueue( NSOperationQueue.currentQueue(), withHandler:{
            deviceManager, error in
            var accel: CMAcceleration = deviceManager.userAcceleration
            
            var gyro: CMRotationRate = deviceManager.rotationRate
//            self.gyro_x.text = String(format: "%.2f", gyro.x)
//            self.gyro_y.text = String(format: "%.2f", gyro.y)
//            self.gyro_z.text = String(format: "%.2f", gyro.z)
//            
            var attitude: CMAttitude = deviceManager.attitude
//            self.attitude_roll.text = String(format: "%.2f", attitude.roll)
//            self.attitude_pitch.text = String(format: "%.2f", attitude.pitch)
//            self.attitude_yaw.text = String(format: "%.2f", attitude.yaw)
            
            var quaternion: CMQuaternion = attitude.quaternion
//            self.attitude_x.text = String(format: "%.2f", quaternion.x)
//            self.attitude_y.text = String(format: "%.2f", quaternion.y)
//            self.attitude_z.text = String(format: "%.2f", quaternion.z)
//            self.attitude_w.text = String(format: "%.2f", quaternion.w)
//            
            if self.isRotate {
 //               var rotDegree : CGFloat = CGFloat(360 - ((attitude.yaw * 180)/M_PI + 360)%360)
                var rotDegree : CGFloat = CGFloat(((attitude.yaw * 180)/M_PI + 360)%360)
                var diff = self.mCurrentDegree - rotDegree
                
                if diff > 2 || diff < -2 {
                    self.rotateButton.transform = CGAffineTransformMakeRotation(CGFloat(rotDegree/180 * CGFloat(M_PI)))
                
                    var rotFunction = "rotateMap(" + String(format: "%.2f", rotDegree) + ")" as String
                    
                    self.webView!.evaluateJavaScript(rotFunction, completionHandler: nil)
                    self.mCurrentDegree = rotDegree
                    
                }
            }
            else {
            
            }
         })

        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set top title and back image
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 110, height: 20))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "Title")
        imageView.image = image
        
        navigationItem.titleView = imageView
        
        navigationItem.titleView = imageView
        let backBtn = UIBarButtonItem(image:UIImage(named:"back-18.png"), style:.Plain, target:self, action:"barButtonItemClicked:")
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.grayColor()

        
        self.view.backgroundColor = UIColor.blackColor()
        // ----------------------------------------------------

        setup()
        
        self.view.bringSubviewToFront(rotateButton)
    }
    
    func barButtonItemClicked(sender:UIButton!)
    {
//        let mainvc = self.storyboard!.instantiateViewControllerWithIdentifier("OptionScreen") as! OptionViewController
//        self.navigationController?.pushViewController(mainvc, animated: true)
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func setup(){
    
        var mapNo = 1
        
        if (mPark!.hasPrefix("L2") && mCurrent!.hasPrefix("L3")) {
            mState = 2;
        } else if (mPark!.hasPrefix("L3") && mCurrent!.hasPrefix("L2")) {
            mState = 2;
        } else {
            mState = 1;
        }
        
        if mCurrent!.hasPrefix("L2") {
            mapNo = 0
        }
        else if mCurrent!.hasPrefix("L3") {
            
            mapNo = 1
        }
        
        var url = NSURL(fileURLWithPath:  g_URL[mapNo])
        
        var req = NSURLRequest(URL: url!)
        
        self.webView!.loadRequest(req)
    
    }
    
    func userContentController(userContentController: WKUserContentController,didReceiveScriptMessage message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            mState = 3
            mPoint = message.body as? String
            
            var mapNo = 1
            
            
            if mCurrent!.hasPrefix("L2") {
                mapNo = 1
            }
            else if mCurrent!.hasPrefix("L3") {
                
                mapNo = 0
            }
            // var url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(mapNo, ofType: "html", inDirectory:"assets")!)
            var url = NSURL(fileURLWithPath: g_URL[mapNo])
            
            var req = NSURLRequest(URL: url!)
            self.webView!.loadRequest(req)
        } }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rotate(sender: AnyObject) {
        self.isRotate = !self.isRotate
        if self.isRotate {
            rotateButton.image = UIImage(named: "ic_compass_selected")
        }
        else{
            rotateButton.image = UIImage(named: "ic_compass")
            mCurrentDegree = 0
            webView!.evaluateJavaScript("rotateMap(0)", completionHandler: nil)
            self.rotateButton.transform = CGAffineTransformMakeRotation(CGFloat(0))

        }
    }
    // delegate functions of WKNavigationDelegate
    //

    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        NSLog("%s", __FUNCTION__)
        
        if mState == 1 {
            webView.evaluateJavaScript("drawMap('" + mCurrent! + "', '" + mPark! + "')", completionHandler: nil)
        } else if mState == 2 {
            webView.evaluateJavaScript("drawFrom('" + mCurrent! + "')", completionHandler: nil)
        } else if mState == 3 {
            webView.evaluateJavaScript("drawTo('" + mPoint! + "', '" + mPark! + "')", completionHandler: nil)
        }
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        NSLog("%s. With Error %@", __FUNCTION__,error)
        //showAlertWithMessage("Failed to load file with error \(error.localizedDescription)!")
    }
    
    
    @IBAction func recallScanning(sender: AnyObject) {
        //self.navigationController?.popViewControllerAnimated(true)
        delegate.didFinishMakeVC(self)
    }
    
    
}
