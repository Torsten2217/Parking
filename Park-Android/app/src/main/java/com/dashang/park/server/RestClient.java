package com.dashang.park.server;


import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.PersistentCookieStore;
import com.loopj.android.http.RequestParams;

public class RestClient {
    private static final String BASE_URL = "http://zgpulai.com/api/controller/";

    private static AsyncHttpClient client = new AsyncHttpClient();


    public static void post(String ApiUrl, RequestParams params,
                            AsyncHttpResponseHandler responseHandler) {

        client.post(BASE_URL+ApiUrl+".php", params, responseHandler);
    }

    public static void get(String ApiUrl, RequestParams params,
                            AsyncHttpResponseHandler responseHandler) {

        client.get(ApiUrl, params, responseHandler);
    }

}
