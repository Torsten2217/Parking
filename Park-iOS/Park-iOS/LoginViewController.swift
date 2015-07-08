//
//  LoginViewController.swift
//  Park-iOS
//
//  Created by Dieter Kohl on 5/7/15.
//  Copyright (c) 2015 Dieter Kohl. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,  UITextFieldDelegate, WXApiDelegate , loginProtocol{

    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    var timer:NSTimer?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        
        let token :  String? = prefs.objectForKey("token") as? String
        if(token != nil){
        
            let isLoggedIn = token!.isEmpty as Bool
            if(!isLoggedIn){
                let mainvc = self.storyboard!.instantiateViewControllerWithIdentifier("OptionScreen") as! OptionViewController
//                self.navigationController?.popViewControllerAnimated(true)
                self.navigationController?.pushViewController(mainvc, animated: true)
            
 //             self.performSegueWithIdentifier("goto_option", sender: true)
             }
            
//            else{
//                self.usernameTextField.text = prefs.valueForKey("username") as? String
//            }
        }
        self.usernameTextField.text = prefs.valueForKey("username") as? String
    }
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
	      
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 110, height: 20))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "Title")
        imageView.image = image
        
        navigationItem.titleView = imageView
        self.navigationItem.setHidesBackButton(true, animated: true)

//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "222"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowOffset = CGSizeMake(0, 1)
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.6
       
        
        self.usernameTextField.delegate = self;
        self.passwordTextField.delegate = self;
    }
    func onUpdate(){
        
        let bValue : Bool = login()
        if bValue != true {
            self.view.hideToastActivity()
            return
        }
        
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("OptionScreen") as! OptionViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
        self.view.hideToastActivity()

    }
    @IBAction func loginBtnProcess(sender: AnyObject) {
        
        self.view.makeToastActivity()
        
        timer?.invalidate()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "onUpdate", userInfo: nil, repeats: false)
        
//        let bValue : Bool = login()
//        if bValue != true {
//            self.view.hideToastActivity()
//            return
//        }
//        
//        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("OptionScreen") as! OptionViewController
//        self.navigationController?.pushViewController(vc, animated: true)
//
//        self.view.hideToastActivity()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Login part
    func login()-> Bool {
        
        var username:NSString = usernameTextField.text
        var password:NSString = passwordTextField.text
        
        if(username.isEqualToString("") || password.isEqualToString("")){
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "警告"
            alertView.message = "请输入用户名和密码"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else{
            var post:NSString = "username=\(username)&password=\(password)"
            NSLog("PostData: %@", post)
            
            var url:NSURL = NSURL(string: "http://zgpulai.com/api/controller/login.php")!
            
            var postdata:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
            
            var postLenght:NSString = String(postdata.length)
            
            var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            
            request.HTTPMethod = "POST"
            request.HTTPBody = postdata
            request.setValue(postLenght as String, forHTTPHeaderField: "Content-Lenght")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            var responseError: NSError?
            var response: NSURLResponse?
            
            var urlData:NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &responseError)
            
            if(urlData != nil){
                let res = response as! NSHTTPURLResponse!
                
                NSLog("Response code: %ld", res.statusCode)
                
                if(res.statusCode >= 200 && res.statusCode < 300){
                    var responseData:NSString = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                    
                    NSLog("Response ==> %@", responseData)
                    
                    var error: NSError?
                    
                    let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
                    
                    let status:NSInteger = jsonData.valueForKey("status") as! NSInteger
                    
                    //[jsonData[@"success"] integerValue]
                    
                    NSLog("status: %ld", status)
                    
                    if(status == 1){
                        NSLog("Sign Up Success")
                        let token:String = jsonData.valueForKey("token") as! String

                        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        prefs.setObject(username, forKey: "username")
                        prefs.setObject(token, forKey: "token")
                        prefs.synchronize()
                        
//                      self.dismissViewControllerAnimated(true, completion: nil)
                        return true
                    } else{
                        var error_msg:NSString
                        
                        if(jsonData["msg"] as? NSString != nil){
                            error_msg = jsonData["msg"] as! String
                        } else{
                            error_msg = "未知错误"
                        }
                        if let viewWithTag = self.view.viewWithTag(100) {
                            return false
                        }
                        showMsgDialog(error_msg)
                     }
                } else{
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "警告"
                    alertView.message = "连接失败"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
            } else {
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "警告"
                alertView.message = "连接错误3"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        }
        
        return false

    }
    
    func showMsgDialog(msg:NSString){
        var DynamicView=UIView(frame: CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40))
        
        let button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        
        
        let label = UILabel() as UILabel
        label.frame = CGRectMake(5, 1, self.view.frame.size.width - 50, 35)
        label.textColor = UIColor.whiteColor()
        label.text = msg as String
        label.textAlignment = NSTextAlignment.Left
        DynamicView.addSubview(label)
        
        button.setTranslatesAutoresizingMaskIntoConstraints(true)
        button.setTitle("确定", forState: UIControlState.Normal)
        button.addTarget(self, action: "buttonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        button.backgroundColor = UIColor.blackColor()
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.frame = CGRectMake(self.view.frame.size.width - 50, 1, 50, 40)
        DynamicView.addSubview(button)
        
        DynamicView.backgroundColor=UIColor.blackColor()
        DynamicView.layer.cornerRadius=5
        DynamicView.layer.borderWidth=2
        DynamicView.tag = 100
        self.view.addSubview(DynamicView)
        
    }
    func buttonPressed(){
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        
    }

    @IBAction func qqLoginProcess(sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("qqloginID") as! QQLoginViewController
        self.navigationController?.pushViewController(vc, animated: true)
        self.view.hideToastActivity()
    }
    
    @IBAction func weChatLoginProcess(sender: AnyObject) {
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        app.loginWeChat()
        app.delegate = self
    }
    
    func callOptionVC(type:Int){
        let mainvc = self.storyboard!.instantiateViewControllerWithIdentifier("OptionScreen") as! OptionViewController
 //       self.navigationController?.popViewControllerAnimated(true)
        self.navigationController?.pushViewController(mainvc, animated: true)
    }
    
    func onForget() {
        
        var post:NSString = "username=\(usernameTextField.text)"
        
        NSLog("PostData: %@", post)
        
        var url:NSURL = NSURL(string: "http://zgpulai.com/api/controller/forgot.php")!
        
        var postdata:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        
        var postLenght:NSString = String(postdata.length)
        
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = postdata
        request.setValue(postLenght as String, forHTTPHeaderField: "Content-Lenght")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var responseError: NSError?
        var response: NSURLResponse?
        
        var urlData:NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &responseError)
        
        if(urlData != nil){
            let res = response as! NSHTTPURLResponse!
            
            NSLog("Response code: %ld", res.statusCode)
            
            if(res.statusCode >= 200 && res.statusCode < 300){
                var responseData:NSString = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                
                NSLog("Response ==> %@", responseData)
                
                var error: NSError?
                
                let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
                
                let status:NSInteger = jsonData.valueForKey("status") as! NSInteger
                
                //[jsonData[@"success"] integerValue]
                
                NSLog("status: %ld", status)
                
                var error_msg:NSString
                
                if(status == 1){
                    error_msg = "密码已传送到电邮"
                } else{
                    if(jsonData["msg"] as? NSString != nil){
                        error_msg = jsonData["msg"] as! String
                    } else{
                        error_msg = "未知错误"
                    }
                    if let viewWithTag = self.view.viewWithTag(100) {
                        self.view.hideToastActivity()
                        return
                    }
                }
                showMsgDialog(error_msg)
                
            } else{
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "警告"
                alertView.message = "连接失败"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        } else {
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "警告"
            alertView.message = "连接错误4"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        self.view.hideToastActivity()
    }
    
    @IBAction func forgetProcess(sender: AnyObject) {
        
        // userName validcheck
        if  usernameTextField.text.isEmpty || count(usernameTextField.text) < 4 {
            usernameTextField.becomeFirstResponder()
            return
        }
        
        self.view.makeToastActivity()
        
        timer?.invalidate()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "onForget", userInfo: nil, repeats: false)
        
        
       }
}
