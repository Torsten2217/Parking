//
//  AccountTableViewController.swift
//  Park-iOS
//
//  Created by Dieter Kohl on 5/17/15.
//  Copyright (c) 2015 Dieter Kohl. All rights reserved.
//

import UIKit

class AccountTableViewController: UITableViewController,  UITextFieldDelegate {
//class AccountTableViewController: UITableViewController,  UITextFieldDelegate {
//// pesonal information setting
    

    
    var  accountInfo : NSDictionary!
    
    
    var mToken:String!
    
    
    @IBAction func pesonalUpdate(sender: AnyObject){
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        mToken = prefs.objectForKey("token") as! String
        
        let cell = tableView.dequeueReusableCellWithIdentifier("accountInfo") as! AccountTableViewCell
        
        getJsonData(1, addpost: "name=\(cell.txtName)&phone=\(cell.txtPhone)&email=\(cell.txtEmail)&token=\(mToken)")
    }
    
    
    
    @IBAction func accountUpdate(sender: AnyObject) {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        mToken = prefs.objectForKey("token") as! String
        
        let cell = tableView.dequeueReusableCellWithIdentifier("accountInfo") as! AccountTableViewCell
        getJsonData(1, addpost: "username=\(cell.txtUser)&password=\(cell.txtPass)&token=\(mToken)")

    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 110, height: 20))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "Title")
        imageView.image = image
        
        navigationItem.titleView = imageView
        let backBtn = UIBarButtonItem(image:UIImage(named:"back-18.png"), style:.Plain, target:self, action:"barButtonItemClicked:")
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.grayColor()
        
        getAccount()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
    }
    
    func barButtonItemClicked(sender:UIButton!)
    {
          self.navigationController?.popViewControllerAnimated(true)        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
          return 1
    }

    // Get informations(pesonal and Account)
    func  getJsonData(type:Int,addpost : String)-> NSDictionary {
        
//        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//        mToken = prefs.objectForKey("token") as! String
// 
        self.view.makeToastActivity()
        
        var post:NSString = addpost
        
        NSLog("PostData: %@", post)
        
        var url:NSURL!
        if(type == 0){
            url = NSURL(string: "http://zgpulai.com/api/controller/account.php")!
        } else {
            url = NSURL(string: "http://zgpulai.com/api/controller/update.php")!
        }
        
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
                
                let jsonData : NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
                
                let status:NSInteger = jsonData.valueForKey("status") as! NSInteger
                
                NSLog("status: %ld", status)
                
                if(status == 1){
                    NSLog("Sign Up Success")
                   //                      self.dismissViewControllerAnimated(true, completion: nil)
                    self.view.hideToastActivity()

                    return jsonData
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
            alertView.message = "连接错误2"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        
        self.view.hideToastActivity()
       return NSDictionary()
    }

    func getAccount(){
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        mToken = prefs.objectForKey("token") as! String
 
        let jsonData = getJsonData(0, addpost: "token=\(mToken)")
        
        println(jsonData["status"])
        
        
        let status:NSInteger? = jsonData.valueForKey("status") as? NSInteger
        
        
        if(status == 1){
            NSLog("Read Success")
            
            accountInfo = jsonData.valueForKey("result") as! NSDictionary
            
            
            
        } else{
            var error_msg:NSString

            if(jsonData["msg"] as? NSString != nil){
                error_msg = jsonData["msg"] as! String
            } else{
                error_msg = "未知错误"
            }
            self.showMsgDialog(error_msg)
        }
    
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("accountInfo", forIndexPath: indexPath) as! AccountTableViewCell

        
        let result : NSDictionary = accountInfo
        
        var tempStr : String? = result.valueForKey("name") as? String
        
        if(tempStr?.isEmpty == false){
            cell.txtName.text = tempStr
        }
        
        tempStr = result.valueForKey("email") as? String
        
        if(tempStr?.isEmpty == false){
            cell.txtEmail.text = tempStr
        }
        
        tempStr = result.valueForKey("phone") as? String
        
        if(tempStr?.isEmpty == false){
            cell.txtPhone.text = tempStr
        }
        
        tempStr = result.valueForKey("username") as? String
        
        if(tempStr?.isEmpty == false){
            cell.txtUser.text = tempStr
        }
          
        
        let resQQ : String? = result.valueForKey("qq_id") as? String
        let resWeChat : String? = result.valueForKey("wechat_id") as? String
        if(resWeChat?.isEmpty == false){
            cell.weChat!.setOn(true, animated: true)
        }
        if(resQQ?.isEmpty == false){
            cell.qqSwitch!.setOn(true, animated: true)
        }
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
