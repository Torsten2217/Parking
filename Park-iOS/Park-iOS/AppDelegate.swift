//
//  AppDelegate.swift
//  Park-iOS
//
//  Created by Dieter Kohl on 5/6/15.
//  Copyright (c) 2015 Dieter Kohl. All rights reserved.
//

import UIKit
import CoreData

// web page urls
var g_URL : [String] = [ "", ""]

protocol loginProtocol{
    //define a method and receive a Dectonary
    func callOptionVC(type:Int)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {

    var window: UIWindow?
    var delegate : loginProtocol?
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var isRegister : Bool?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        createTempDirectory()
        
        isRegister = prefs.objectForKey("wechat_register") as? Bool
        
        WXApi.registerApp(stringHelper.WECHAT_APP_ID)
        
        return true
    }
    
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }
    
    func onReq(req: BaseReq!) {
        
    }
    
 
    func onResp( resp : BaseResp ){
        
        var temp : SendAuthResp = resp as! SendAuthResp
        
        if(resp.errCode != 0){
            return
        }
        
        if resp.isKindOfClass(SendAuthResp) {

            getOpenId(temp.code)
            
        }
//        else {
//            var alertView:UIAlertView = UIAlertView()
//            alertView.title = "警告"
//            alertView.message = "\(temp.errCode)" as String
//            alertView.delegate = self
//            alertView.addButtonWithTitle("OK")
//            alertView.show()
//        }
    }
    
// 
    
    
    func loginWeChat() {
        
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        prefs.setObject(true, forKey: "wechat_register")
        prefs.synchronize()
        
        let req : SendAuthReq = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "123"
        WXApi.sendReq(req)
    }

    
    
    func getOpenId(code : String) {
    
        // create the request & response
        var url : String = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=\(stringHelper.WECHAT_APP_ID)&secret=\(stringHelper.WECHAT_SECRET)&code=\(code)&grant_type=authorization_code"
        
        var request : NSMutableURLRequest = NSMutableURLRequest()
        var response: NSURLResponse?
        var error: NSError?
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        
        // send the request
        var dataVal: NSData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)!
        let jsonResponse: NSDictionary! = NSJSONSerialization.JSONObjectWithData(dataVal, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
        
         NSLog("Response ==> %@", jsonResponse)
        
        // look at the response
        if (jsonResponse != nil) {

            let accessToken:String = jsonResponse.valueForKey("access_token") as! String
            let openId:String = jsonResponse.valueForKey("openid") as! String
            
            self.getUsername(openId, accessToken: accessToken)
        }
        else {
            showMsgDialog("No HTTP response")
        }
    }
    
    func getUsername(openID : String, accessToken : String) {
        
        
        // create the request & response
        var url : String = "https://api.weixin.qq.com/sns/userinfo?access_token=\(accessToken)&openid=\(openID)"
        
        var request : NSMutableURLRequest = NSMutableURLRequest()
        var response: NSURLResponse?
        var error: NSError?
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        
        // send the request
        var dataVal: NSData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)!
        let jsonResponse: NSDictionary! = NSJSONSerialization.JSONObjectWithData(dataVal, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
        
        NSLog("jsonResponse ==> %@", jsonResponse)
        
        // look at the response
        if (jsonResponse != nil) {
             let nickName:String = jsonResponse.valueForKey("nickname") as! String
              register(openID, nickname: nickName)
            
        }
        else {
            showMsgDialog("No HTTP response")
        }
    }

    func register(openID : String, nickname : String){
        var post:NSString = "wechat=\(openID)&username=\(nickname)"
        NSLog("PostData: %@", post)
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        isRegister = prefs.objectForKey("wechat_register") as? Bool
        
        var url:NSURL
        if self.isRegister! {
            url = NSURL(string: "http://zgpulai.com/api/controller/register.php")!
        }
        else {
            url = NSURL(string: "http://zgpulai.com/api/controller/connect.php")!
        }
        
        var postdata:NSData = post.dataUsingEncoding(NSUTF8StringEncoding)!
        
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
                    delegate?.callOptionVC(10)
                    
                      //                      self.dismissViewControllerAnimated(true, completion: nil)
                }
                else{
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
            showMsgDialog("连接错误1")
        }
    }
    func showMsgDialog(msg:NSString){
        
        var alertView:UIAlertView = UIAlertView()
        alertView.title = "警告"
        alertView.message = msg as String
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.dashang.Park_iOS" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Park_iOS", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Park_iOS.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    //MARK: - web pages temp directory create
    func createTempDirectory() -> String? {
        
        let tempDirectoryTemplate : String = NSTemporaryDirectory().stringByAppendingPathComponent("parkWWW")
        
        let fileManager = NSFileManager.defaultManager()
        
        var isDirectory: ObjCBool = false
        if NSFileManager.defaultManager().fileExistsAtPath(tempDirectoryTemplate, isDirectory: &isDirectory) {
            if(isDirectory) {
//               fileManager.removeItemAtPath(tempDirectoryTemplate, error: nil)
                g_URL[0] = tempDirectoryTemplate.stringByAppendingPathComponent("map1.html")
                g_URL[1] = tempDirectoryTemplate.stringByAppendingPathComponent("map2.html")
                
                return nil
            }
        }
        var sourceUrl = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("assets")
        
        let filelist = fileManager.contentsOfDirectoryAtPath(sourceUrl, error: nil)
        
        var count = 0
        for filename in filelist! {
            count++
        }
        
        var err: NSErrorPointer = nil
        if fileManager.createDirectoryAtPath(tempDirectoryTemplate, withIntermediateDirectories: true, attributes: nil, error: err) {
            
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: sourceUrl)!, toURL: NSURL(fileURLWithPath: tempDirectoryTemplate)!, error: nil)
            
            var kk = tempDirectoryTemplate.stringByAppendingPathComponent("map1.html")
            var src = sourceUrl.stringByAppendingPathComponent("map1.html")
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: src)!, toURL: NSURL(fileURLWithPath: kk )!, error: nil)
            g_URL[0] = kk
            
            kk = tempDirectoryTemplate.stringByAppendingPathComponent("map2.html")
            src = sourceUrl.stringByAppendingPathComponent("map2.html")
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: src)!, toURL: NSURL(fileURLWithPath: kk )!, error: nil)
            g_URL[1] = kk
            
            // create folder js
            
            var tempDirectoryTemplate2 = tempDirectoryTemplate.stringByAppendingPathComponent("js")
            var sourceUrl2 = sourceUrl.stringByAppendingPathComponent("js")
            
            
            
            fileManager.createDirectoryAtPath(tempDirectoryTemplate2, withIntermediateDirectories: true, attributes: nil, error: err)
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: sourceUrl2)!, toURL: NSURL(fileURLWithPath: tempDirectoryTemplate2 )!, error: nil)
            
            kk = tempDirectoryTemplate2.stringByAppendingPathComponent("map1.js")
            src = sourceUrl2.stringByAppendingPathComponent("map1.js")
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: src)!, toURL: NSURL(fileURLWithPath: kk )!, error: nil)
            
            kk = tempDirectoryTemplate2.stringByAppendingPathComponent("map2.js")
            src = sourceUrl2.stringByAppendingPathComponent("map2.js")
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: src)!, toURL: NSURL(fileURLWithPath: kk )!, error: nil)
            
            kk = tempDirectoryTemplate2.stringByAppendingPathComponent("jquery.min.js")
            src = sourceUrl2.stringByAppendingPathComponent("jquery.min.js")
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: src)!, toURL: NSURL(fileURLWithPath: kk )!, error: nil)
            
            kk = tempDirectoryTemplate2.stringByAppendingPathComponent("data1.js")
            src = sourceUrl2.stringByAppendingPathComponent("data1.js")
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: src)!, toURL: NSURL(fileURLWithPath: kk )!, error: nil)
            
            kk = tempDirectoryTemplate2.stringByAppendingPathComponent("data2.js")
            src = sourceUrl2.stringByAppendingPathComponent("data2.js")
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: src)!, toURL: NSURL(fileURLWithPath: kk )!, error: nil)
            
            
            // create folder img
            tempDirectoryTemplate2 = tempDirectoryTemplate.stringByAppendingPathComponent("img")
            sourceUrl2 = sourceUrl.stringByAppendingPathComponent("img")
            fileManager.createDirectoryAtPath(tempDirectoryTemplate2, withIntermediateDirectories: true, attributes: nil, error: err)
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: sourceUrl2)!, toURL: NSURL(fileURLWithPath: tempDirectoryTemplate2 )!, error: nil)
            
            
            kk = tempDirectoryTemplate2.stringByAppendingPathComponent("nav.png")
            src = sourceUrl2.stringByAppendingPathComponent("nav.png")
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: src)!, toURL: NSURL(fileURLWithPath: kk )!, error: nil)
            
            kk = tempDirectoryTemplate2.stringByAppendingPathComponent("map-1.png")
            src = sourceUrl2.stringByAppendingPathComponent("map-1.png")
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: src)!, toURL: NSURL(fileURLWithPath: kk )!, error: nil)
            
            kk = tempDirectoryTemplate2.stringByAppendingPathComponent("map-2.png")
            src = sourceUrl2.stringByAppendingPathComponent("map-2.png")
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: src)!, toURL: NSURL(fileURLWithPath: kk )!, error: nil)
            
            kk = tempDirectoryTemplate2.stringByAppendingPathComponent("car.png")
            src = sourceUrl2.stringByAppendingPathComponent("car.png")
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: src)!, toURL: NSURL(fileURLWithPath: kk )!, error: nil)
            
            
            // create folder css
            tempDirectoryTemplate2 = tempDirectoryTemplate.stringByAppendingPathComponent("css")
            sourceUrl2 = sourceUrl.stringByAppendingPathComponent("css")
            fileManager.createDirectoryAtPath(tempDirectoryTemplate2, withIntermediateDirectories: true, attributes: nil, error: err)
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: sourceUrl2)!, toURL: NSURL(fileURLWithPath: tempDirectoryTemplate2 )!, error: nil)
            
            kk = tempDirectoryTemplate2.stringByAppendingPathComponent("map1.css")
            src = sourceUrl2.stringByAppendingPathComponent("map1.css")
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: src)!, toURL: NSURL(fileURLWithPath: kk )!, error: nil)
            
            
            kk = tempDirectoryTemplate2.stringByAppendingPathComponent("map2.css")
            src = sourceUrl2.stringByAppendingPathComponent("map2.css")
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: src)!, toURL: NSURL(fileURLWithPath: kk )!, error: nil)
            
            kk = tempDirectoryTemplate2.stringByAppendingPathComponent("bootstrap.css")
            src = sourceUrl2.stringByAppendingPathComponent("bootstrap.css")
            fileManager.copyItemAtURL(NSURL(fileURLWithPath: src)!, toURL: NSURL(fileURLWithPath: kk )!, error: nil)

            
//            
//            // create folder bootstrap
//            tempDirectoryTemplate2 = tempDirectoryTemplate.stringByAppendingPathComponent("bootstrap").stringByAppendingPathComponent("css")
//            sourceUrl2 = sourceUrl.stringByAppendingPathComponent("bootstrap").stringByAppendingPathComponent("css")
//            fileManager.createDirectoryAtPath(tempDirectoryTemplate2, withIntermediateDirectories: true, attributes: nil, error: err)
//            fileManager.copyItemAtURL(NSURL(fileURLWithPath: sourceUrl2)!, toURL: NSURL(fileURLWithPath: tempDirectoryTemplate2 )!, error: nil)
//            
//            kk = tempDirectoryTemplate2.stringByAppendingPathComponent("bootstrap.css")
//            src = sourceUrl2.stringByAppendingPathComponent("bootstrap.css")
//            fileManager.copyItemAtURL(NSURL(fileURLWithPath: src)!, toURL: NSURL(fileURLWithPath: kk )!, error: nil)
            
            return tempDirectoryTemplate
        } else {
            return nil
        }
    }
    
    
    

}

