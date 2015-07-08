//
//  RegisterViewController.swift
//  Park-iOS
//
//  Created by Dieter Kohl on 5/9/15.
//  Copyright (c) 2015 Dieter Kohl. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController,  UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var realNameTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 110, height: 20))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "Title")
        imageView.image = image
        
        navigationItem.titleView = imageView
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        self.realNameTextField.delegate = self
        self.mailTextField.delegate = self
        self.phoneNumberTextField.delegate = self
   
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
    }
    
    @IBAction func register(sender: AnyObject) {
        
        var username:NSString = usernameTextField.text as NSString
        var password:NSString = passwordTextField.text as NSString
        var confirmPass:NSString = confirmPasswordTextField.text as NSString
        var realUsername:NSString = realNameTextField.text as NSString
        var email:NSString = mailTextField.text as NSString
        var phoneNumber:NSString = phoneNumberTextField.text as NSString
        
        if(username.isEqualToString("") || password.isEqualToString("")){
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "警告"
            alertView.message = "密码最少6个字，最少一个字母，最少一个数字"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else if(!password.isEqual(confirmPass)){
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "警告"
            alertView.message = "密码不符合"
            alertView.delegate = self
            alertView.addButtonWithTitle("确定")
            alertView.show()
            
        } else{
            var post:NSString = "username=\(username)&password=\(password)&name=\(realUsername)&phone=\(phoneNumber)&email=\(email)"
            NSLog("Post Data: %@", post)
            
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
 //                       self.dismissViewControllerAnimated(true, completion: nil)
                        showMsgDialog(jsonData["msg"] as! String)
                        
                    } else{
                        var error_msg:NSString
                        
                        if(jsonData["msg"] as? NSString != nil){
                            error_msg = jsonData["msg"] as! NSString
                        } else{
                            error_msg = "未知错误"
                        }
                        
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "警告"
                        alertView.message = error_msg as String
                        alertView.delegate = self
                        alertView.addButtonWithTitle("确定")
                        alertView.show()
                    }
                } else{
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "警告"
                    alertView.message = "连接失败"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("确定")
                    alertView.show()
                }
            } else {
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "警告"
                alertView.message = "连接错误"
                alertView.delegate = self
                alertView.addButtonWithTitle("确定")
                alertView.show()
            }
            
        }
    }
    func showMessage(message:NSString) {
        var alertView:UIAlertView = UIAlertView()
        alertView.title = "警告"
        alertView.message = message as String
        alertView.delegate = self
        alertView.addButtonWithTitle("确定")
        alertView.show()

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
        DynamicView.tag = 101
        self.view.addSubview(DynamicView)
        
    }
    func buttonPressed(){
        if let viewWithTag = self.view.viewWithTag(101) {
            viewWithTag.removeFromSuperview()
            self.navigationController?.popViewControllerAnimated(true)
        }
        
    }
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
