package com.dashang.park.helper;

import android.text.TextUtils;

import org.w3c.dom.Text;

import java.text.DecimalFormat;


public class StringHelper {

    public static final String ANDROID_ARM="http://zgpulai.com/park_arm.apk";
    public static final String ANDROID_X86="http://zgpulai.com/park_x86.apk";
    public static final String IOS="http://itunes.com/apps/";
    public static final String QQ_APP_ID = "101210291";
    public static final String WECHAT_APP_ID = "wxe83bdfef70a4ba4f";
    public static final String WECHAT_SECRET = "ebfd1fe4fd57b890d57fc4dd3ecc7e96";

    public static boolean isPasswordValid(String password) {
        return password.matches("(?!^[0-9]*$)(?!^[a-zA-Z]*$)^([a-zA-Z0-9]{6,20})$");
    }

    public static String getLoc(String loc) {
        String result;
        if(TextUtils.isEmpty(loc)){
            result = "未停车";
        }else {
            result = "郑州大商新玛特金博大店";
            if (loc.startsWith("L2")) {
                result += "负二层";
            } else if (loc.startsWith("L3")) {
                result += "负三层";
            }
            String[] parts = loc.split("-");
            if(parts.length>1) {
                result += " " + parts[1];
            }else{
                result = "未停车";
            }
        }
        return result;
    }


    public static boolean isEmailValid(String email) {
        String ePattern = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\])|(([a-zA-Z\\-0-9]+\\.)+[a-zA-Z]{2,}))$";
        java.util.regex.Pattern p = java.util.regex.Pattern.compile(ePattern);
        java.util.regex.Matcher m = p.matcher(email);
        return m.matches();
    }


    public static boolean isPhoneValid(String phone) {
        if (phone.length() < 6) {
            return false;
        }
        String ePattern = "^[0-9]*$";
        java.util.regex.Pattern p = java.util.regex.Pattern.compile(ePattern);
        java.util.regex.Matcher m = p.matcher(phone);
        return m.matches();
    }

}
