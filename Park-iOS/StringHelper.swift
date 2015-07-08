//
//  StringHelper.swift
//  Park-iOS
//
//  Created by Dieter Kohl on 5/14/15.
//  Copyright (c) 2015 Dieter Kohl. All rights reserved.
//

import Foundation

class stringHelper : NSObject{

    class var ANDROID_ARM : String { return "http://zgpulai.com/park_arm.apk" }
    
    class var ANDROID_X86 : String { return  "http://zgpulai.com/park_x86.apk"}
    class var IOS : String { return  "http://zgpulai.com/park_arm.apk"}

    class var QQ_APP_ID : String { return "101210291"}

    class var WECHAT_APP_ID : String { return  "wxe83bdfef70a4ba4f"}

    class var WECHAT_SECRET : String { return  "ebfd1fe4fd57b890d57fc4dd3ecc7e96"}
    
    class var BASE_URL : String{return "http://zgpulai.com/api/controller/"}
    
    class func isEmailValid(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    

     class func validate(value: String) -> Bool {

        let PHONE_REGEX = "^\\d{10}$"

        var phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        return phoneTest.evaluateWithObject(value)
    }
    
    class func isPasswordValid(value: String) -> Bool
    {
        let PW_REGEX = "(?!^[0-9]*$)(?!^[a-zA-Z]*$)^([a-zA-Z0-9]{6,20})$"
        
        var phoneTest = NSPredicate(format: "SELF MATCHES %@", PW_REGEX)
        return phoneTest.evaluateWithObject(value)
    
    }
    
    class func getLoc(loc : String) -> String {
        var  result : String
        
        if loc.isEmpty == true{
            result = "未停车"
        }
        else {
            result = "郑州大商新玛特金博大店"
            if loc.hasPrefix("L2"){
                result += "负二层"
              }else if loc.hasPrefix("L3"){
                 result += "负三层"
            }
            
            let strArray = loc.componentsSeparatedByString("-")
            if strArray.count > 1{
                result += " " + strArray[1]
            }
            else{
                result = "未停车"
            }
        }
        
        return result
    }
}
