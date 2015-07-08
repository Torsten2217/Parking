//
//  OptionViewController.swift
//  Park_iOS
//
//  Created by Dieter Kohl on 5/2/15.
//  Copyright (c) 2015 Dieter Kohl. All rights reserved.
//

import UIKit
import AVFoundation

var g_Park : String = ""
var g_Current : String = ""

class OptionViewController: UIViewController , QRCodeReaderViewControllerDelegate, MainViewControllerDelegate {
   
    @IBOutlet weak var locName: UILabel!
 
    @IBOutlet weak var parkTime: UILabel!
    
   lazy var reader = QRCodeReaderViewController(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
    var parkFindFlag : Int = 0
   var mainMapVC : MainViewController?
    @IBAction func myAccountMenu(sender: AnyObject) {
        self.view.viewWithTag(100)?.hidden = true
        let mainvc = self.storyboard!.instantiateViewControllerWithIdentifier("AccountID") as! AccountTableViewController
        self.navigationController?.pushViewController(mainvc, animated: true)
    }
 
    @IBAction func touchCapture(sender: AnyObject) {
        let menuView = self.view.viewWithTag(100);
        if(menuView?.hidden == false){
            menuView?.hidden = true
            
        }
    }
    
    @IBAction func shareMenu(sender: AnyObject) {
        self.view.viewWithTag(100)?.hidden = true
        
        let sharingText : String =  "下载郑州大商新玛特金博大店手机软件\n安卓（ARM）: " + "http://zgpulai.com/park_arm.apk"	 + "\n安卓（x86）: " + "http://zgpulai.com/park_x86.apk" + "\niOS : " + "http://itunes.com/apps/"
        let activityViewController = UIActivityViewController(
            activityItems: [sharingText as NSString],
            applicationActivities: nil)
    
        presentViewController(activityViewController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func shareQRMenu(sender: AnyObject) {
        self.view.viewWithTag(100)?.hidden = true
        let mainvc = self.storyboard!.instantiateViewControllerWithIdentifier("QRCodeID") as! QRCodeTableViewController
        self.navigationController?.pushViewController(mainvc, animated: true)

    }
    
    @IBAction func logoutMenu(sender: AnyObject) {
        self.view.viewWithTag(100)?.hidden = true
        
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        prefs.removeObjectForKey("token")
        prefs.synchronize()

        let mainvc = self.storyboard!.instantiateViewControllerWithIdentifier("Login") as! LoginViewController
        self.navigationController?.pushViewController(mainvc, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 110, height: 20))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "Title")
        imageView.image = image
        self.locName.text = "未停车"
        self.parkTime.text = "- : -"
        
        navigationItem.titleView = imageView
        self.navigationItem.setHidesBackButton(true, animated: true)
          // Do any additional setup after loading the view.
       
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        var storeLocName : String?
        storeLocName = prefs.objectForKey("loc") as? String
        if(storeLocName != nil){
            g_Park = storeLocName!
            self.locName.text = stringHelper.getLoc(storeLocName!)
            
        }
        var parkT : String?
        parkT = prefs.objectForKey("parkTime") as? String
        if(parkT == nil || parkT == ""){
            self.parkTime.text = "- : -"
        }
        else {
            self.parkTime.text = parkT
        }
    }

  
    @IBAction func toggleMenu(sender: AnyObject) {
        menuProcess()
    }
    
    func menuProcess(){
    
        let menuView = self.view.viewWithTag(100);
        
        if(menuView?.hidden == true){
            menuView?.hidden = false
            
        }
        else {
            menuView?.hidden = true
        }
    }
    
    func callScanInfo(){
        if QRCodeReader.supportsMetadataObjectTypes() {
            reader.modalPresentationStyle = .FormSheet
            reader.delegate               = self
            
            reader.completionBlock = { (result: String?) in
                println("Completion with result: \(result)")
            }
            
            self.navigationController?.pushViewController(reader, animated: true)
 //           presentViewController(reader, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        }
  
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    @IBAction func stopProcess(sender: AnyObject) {
        
        parkFindFlag = 1 // if is park status parkFindFlag = 1

        self.callScanInfo()
        self.view.viewWithTag(100)?.hidden = true
    }
    
    @IBAction func fuindProcess(sender: AnyObject) {
        
        if g_Park.hasPrefix("L2") || g_Park.hasPrefix("L3")
        {
        
            parkFindFlag = 2 // if is park status parkFindFlag = 2
            self.callScanInfo()
        }
        self.view.viewWithTag(100)?.hidden = true
            
    }
    // MARK: - Navigation

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
         
    }
    func reader(reader: QRCodeReaderViewController, didScanResult result: String) {
        self.navigationController?.popViewControllerAnimated(true)

        if self.parkFindFlag == 1 {
 
//          let vc = self.storyboard!.instantiateViewControllerWithIdentifier("ParkOK") as! ParkOKViewController
//          self.presentViewController(vc, animated: true, completion: nil)
            var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var curTime = NSDate()
            var formatter = NSDateFormatter()
            formatter.dateFormat = "HH:mm a"
            let curTimeStr = formatter.stringFromDate(curTime);
            
            
            self.parkTime.text = "- : -"
            self.locName.text = stringHelper.getLoc(result)
            
            if locName.text!.isEmpty == true{
                g_Park = ""
                return
            }
            else if locName.text!.hasPrefix("未停车")
            {
                g_Park = ""
                return
            }
            
            g_Park = result
            self.parkTime.text = curTimeStr
  
            
            prefs.setObject(g_Park, forKey: "loc")
            prefs.setObject(curTimeStr, forKey: "parkTime")
            prefs.synchronize()

            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("ParkOK") as! ParkOKViewController
            self.navigationController?.pushViewController(vc, animated: true)
        
        }
        else if self.parkFindFlag == 2 {
            g_Current = result
            if g_Current == g_Park {
                
                let alert = UIAlertController(title: "成功", message: "您就在停车位", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
                
                presentViewController(alert, animated: true, completion: nil)
                
                
            }
            else {
                //let mainvc = self.storyboard!.instantiateViewControllerWithIdentifier("MainMap") as! MainViewController
                if g_Current.hasPrefix("L2") || g_Current.hasPrefix("L3")
                {
                    mainMapVC = self.storyboard!.instantiateViewControllerWithIdentifier("MainMap") as? MainViewController
                    mainMapVC?.delegate = self
                    self.navigationController?.pushViewController(mainMapVC!, animated: true)
                }

            }
       }
    }
    
    func readerDidCancel(reader: QRCodeReaderViewController) {
        self.navigationController?.popViewControllerAnimated(true)
        
      }

    @IBAction func linkToMe(sender: AnyObject) {
    }
    
    func didFinishMakeVC(controller:MainViewController){
        controller.navigationController?.popViewControllerAnimated(true)
        parkFindFlag = 1 // if is park status parkFindFlag = 1
        
        self.callScanInfo()
        
    }
}
