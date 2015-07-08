//
//  QQLoginViewController.swift
//  Park-iOS
//
//  Created by Dieter Kohl on 5/14/15.
//  Copyright (c) 2015 Dieter Kohl. All rights reserved.
//

import UIKit
import WebKit

class QQLoginViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate   {

    var webView: WKWebView?
    
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
            name: "QQcallbackHandler"
        )
        
        var config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        //self.webView = WKWebView(frame: self.view.frame, configuration: config)
        
        self.webView = WKWebView(frame:CGRectMake(0, 0, self.view.frame.width, self.view.frame.height), configuration: config)
        
        self.webView?.navigationDelegate = self
        //self.view = self.webView!
        self.view.addSubview(self.webView!)
    }
    
    override func viewDidLoad() {
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
        
        
        
        var strUrl = "https://graph.qq.com/oauth2.0/authorize?client_id=101210291&response_type=token&scope=get_user_info&redirect_uri=http://zgpulai.com/qqconnectios.php&display=mobile"
        //var strUrl = "http://google.com"

        var url = NSURL(string: strUrl)
        
        var req = NSURLRequest(URL: url!)
        
        self.view.makeToastActivity()
 
        self.webView!.loadRequest(req)

        
        
    }
    
    func barButtonItemClicked(sender:UIButton!)
    {
          self.navigationController?.popViewControllerAnimated(true)
        
    }
    func userContentController(userContentController: WKUserContentController,didReceiveScriptMessage message: WKScriptMessage) {
        if(message.name == "QQcallbackHandler") {
            
            let sentData = message.body as! NSDictionary
            let openId : String = sentData["openId"] as! String
            let accessToken : String = sentData["accessToken"] as! String
//
//            var alertView:UIAlertView = UIAlertView()
//            alertView.title = "警告"
//            alertView.message = "openId = \(openId) \n accessToken = \(accessToken)"
//            
//            
//            //            var temp : [String] = (message.body as? [String])!
//            alertView.delegate = self
//            alertView.addButtonWithTitle("OK")
//            alertView.show()
//            
            self.view.makeToastActivity()
             login(openId, accessToken: accessToken)
            self.view.hideToastActivity()

//            var url = NSURL(fileURLWithPath: g_URL[1])
//            
//            var req = NSURLRequest(URL: url!)
//            self.webView!.loadRequest(req)
        }
    }

    func login(openID : String, accessToken : String){

            var post:NSString = "qq=\(openID)"
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
                        prefs.setObject(token, forKey: "token")
                        prefs.synchronize()
                        
                        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("OptionScreen") as! OptionViewController
                        self.navigationController?.pushViewController(vc, animated: true)

                        
                        //                      self.dismissViewControllerAnimated(true, completion: nil)
                    } else if status == 4 {
                        
                        // GetUsername
                        getUsername(openID, accessToken: accessToken)
                    
                    } else{
                        var error_msg:NSString
                        
                        if(jsonData["msg"] as? NSString != nil){
                            error_msg = jsonData["msg"] as! String
                        } else{
                            error_msg = "未知错误"
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
                alertView.message = "连接错误"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
    }
   
    func getUsername(openID : String, accessToken : String) {
    
    
        // create the request & response
        var url : String = "https://graph.qq.com/user/get_user_info?access_token=\(accessToken)&oauth_consumer_key=\(stringHelper.QQ_APP_ID)&openid=\(openID)"
        
        var request : NSMutableURLRequest = NSMutableURLRequest()
        var response: NSURLResponse?
        var error: NSError?
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        
        // send the request
        var dataVal: NSData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)!
        let jsonResponse: NSDictionary! = NSJSONSerialization.JSONObjectWithData(dataVal, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
 

        
        // look at the response
        if (jsonResponse != nil) {
            let status:NSInteger = jsonResponse.valueForKey("ret") as! NSInteger
            if status == 0 {
                let nickName:String = jsonResponse.valueForKey("nickname") as! String
                register(openID, nickname: nickName)
            } else {
                var error_msg:NSString
                
                if(jsonResponse["msg"] as? NSString != nil){
                    error_msg = jsonResponse["msg"] as! String
                } else{
                    error_msg = "未知错误"
                }
                showMsgDialog(error_msg)
            }
            
            
        }
        else {
           showMsgDialog("No HTTP response")
        }
    }

    func register(openID : String, nickname : String){
        var post:NSString = "qq=\(openID)&username=\(nickname)"
        NSLog("PostData: %@", post)
        
        var url:NSURL = NSURL(string: "http://zgpulai.com/api/controller/register.php")!
        
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
                    prefs.setObject(token, forKey: "token")
                    prefs.synchronize()
                    
                    let vc = self.storyboard!.instantiateViewControllerWithIdentifier("OptionScreen") as! OptionViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                    
                    //                      self.dismissViewControllerAnimated(true, completion: nil)
                } else{
                    var error_msg:NSString
                    
                    if(jsonData["msg"] as? NSString != nil){
                        error_msg = jsonData["msg"] as! String
                    } else{
                        error_msg = "未知错误"
                    }
                    showMsgDialog(error_msg)
                }
            } else{
                showMsgDialog("连接失败")
            }
        } else {
            showMsgDialog("连接错误")
        }
    }
    
   func showMsgDialog(msg:NSString){
    
        if let viewWithTag = self.view.viewWithTag(110) {
            viewWithTag.removeFromSuperview()
        }

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
        DynamicView.tag = 110
        self.view.addSubview(DynamicView)
        
    }
    func buttonPressed(){
        if let viewWithTag = self.view.viewWithTag(110) {
            viewWithTag.removeFromSuperview()
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.view.hideToastActivity()
        self.view.makeToastActivity()
    }
    
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        NSLog("%s", __FUNCTION__)
        self.view.hideToastActivity()
     }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        NSLog("%s. With Error %@", __FUNCTION__,error)
        //showAlertWithMessage("Failed to load file with error \(error.localizedDescription)!")
    }

}
