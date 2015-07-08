package com.dashang.park;

import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.app.ActionBarActivity;
import android.support.v7.widget.Toolbar;
import android.text.Html;
import android.view.MenuItem;
import android.webkit.JavascriptInterface;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.afollestad.materialdialogs.MaterialDialog;
import com.dashang.park.helper.StringHelper;
import com.dashang.park.server.RestClient;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;

import org.apache.http.Header;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


public class QQActivity extends ActionBarActivity {
    private WebView webView;
    private MaterialDialog mProgress;
    private int mCount = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_qq);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle(R.string.app_name);
        toolbar.setLogo(R.drawable.ic_logo);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setHomeButtonEnabled(true);


        webView = (WebView) findViewById(R.id.webView);
        webView.setHorizontalScrollBarEnabled(false);
        webView.setVerticalScrollBarEnabled(false);
        webView.getSettings().setJavaScriptEnabled(true);

        webView.addJavascriptInterface(new QQInterface(), "QQAndroid");

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                return false;
            }

            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                super.onPageStarted(view, url, favicon);

                if (mCount > 1) {
                    showProgress();
                }
            }

            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                if (mCount > 0) {
                    mProgress.dismiss();
                }
                mCount++;
            }
        });

        showProgress();
        webView.loadUrl("https://graph.qq.com/oauth2.0/authorize?client_id=" + StringHelper.QQ_APP_ID + "&response_type=token&scope=get_user_info&redirect_uri=http%3A%2F%2Fzgpulai.com%2Fqqconnect.php&display=mobile");
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            // Respond to the action bar's Up/Home button
            case android.R.id.home:
                finish();
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public class QQInterface {


        @JavascriptInterface
        public void success(final String openId, final String accessToken) {
            runOnUiThread(new Runnable() {

                public void run() {

                    login(openId, accessToken);
                }
            });

        }

        @JavascriptInterface
        public void fail() {
            runOnUiThread(new Runnable() {

                public void run() {
                    showAlert("暂时无法登入QQ,请稍后再尝试");
                }
            });

        }
    }


    private void showProgress() {
        if (mProgress == null) {
            mProgress = new MaterialDialog.Builder(this)
                    .content("加载中……")
                    .cancelable(false)
                    .progress(true, 0)
                    .build();
        }
        mProgress.show();
    }


    private void getUsername(final String openId, String accessToken) {

        String url = "https://graph.qq.com/user/get_user_info?access_token=" + accessToken;
        url += "&oauth_consumer_key=" + StringHelper.QQ_APP_ID;
        url += "&openid=" + openId;
        RequestParams params = new RequestParams();

        RestClient.get(url, params, new JsonHttpResponseHandler() {

            @Override
            public void onSuccess(int statusCode, Header[] headers, String responseString) {
                showAlert(getString(R.string.login_fail));
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers,
                                  JSONObject response) {
                try {
                    int status = response.getInt("ret");

                    if (status == 0) {
                        String username = response.getString("nickname");

                        register(openId, username);


                    } else {
                        String msg = response.getString("msg");
                        showAlert(Html.fromHtml(msg).toString());
                    }

                } catch (JSONException ignored) {

                    showAlert(getString(R.string.login_fail));
                    //showError(response.toString());
                }
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers, JSONArray response) {
                showAlert(getString(R.string.login_fail));
            }

            @Override
            public void onFailure(int statusCode, Header[] headers, Throwable throwable, JSONObject errorResponse) {
                showAlert(getString(R.string.login_fail));
            }

            @Override
            public void onFailure(int statusCode, Header[] headers, Throwable throwable, JSONArray errorResponse) {
                showAlert(getString(R.string.login_fail));
            }

            @Override
            public void onFailure(int statusCode, Header[] headers,
                                  String responseString, Throwable throwable) {
                showAlert(getString(R.string.login_fail));
            }
        });


    }


    private void register(String openId, String nickname) {

        RequestParams params = new RequestParams();
        params.put("qq", openId);
        params.put("username", nickname);
        RestClient.post("register", params, new JsonHttpResponseHandler() {

            @Override
            public void onSuccess(int statusCode, Header[] headers, String responseString) {
                showAlert(getString(R.string.login_fail));
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers,
                                  JSONObject response) {
                try {
                    int status = response.getInt("status");

                    if (status == 1) {
                        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(QQActivity.this);
                        SharedPreferences.Editor editor = prefs.edit();
                        String token = response.getString("token");
                        editor.putString("token", token);

                        editor.apply();


                        Intent intent = new Intent(QQActivity.this, OptionActivity.class);
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                        mProgress.dismiss();
                        QQActivity.this.startActivity(intent);
                        QQActivity.this.finish();
                    } else {
                        String msg = response.getString("msg");
                        showAlert(Html.fromHtml(msg).toString());
                    }

                } catch (JSONException ignored) {

                    showAlert(getString(R.string.login_fail));
                }
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers, JSONArray response) {
                showAlert(getString(R.string.login_fail));
            }

            @Override
            public void onFailure(int statusCode, Header[] headers, Throwable throwable, JSONObject errorResponse) {
                showAlert(getString(R.string.login_fail));
            }

            @Override
            public void onFailure(int statusCode, Header[] headers, Throwable throwable, JSONArray errorResponse) {
                showAlert(getString(R.string.login_fail));
            }

            @Override
            public void onFailure(int statusCode, Header[] headers,
                                  String responseString, Throwable throwable) {
                showAlert(getString(R.string.login_fail));
            }
        });
    }

    private void login(final String openId, final String accessToken) {

        showProgress();


        RequestParams params = new RequestParams();
        params.put("qq", openId);
        RestClient.post("login", params, new JsonHttpResponseHandler() {

            @Override
            public void onSuccess(int statusCode, Header[] headers, String responseString) {
                showAlert(getString(R.string.login_fail));
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers,
                                  JSONObject response) {
                try {
                    int status = response.getInt("status");

                    if (status == 1) {
                        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(QQActivity.this);
                        SharedPreferences.Editor editor = prefs.edit();
                        String token = response.getString("token");
                        editor.putString("token", token);

                        editor.apply();


                        Intent intent = new Intent(QQActivity.this, OptionActivity.class);
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                        mProgress.dismiss();
                        QQActivity.this.startActivity(intent);
                        QQActivity.this.finish();

                    } else if (status == 4) {
                        getUsername(openId, accessToken);
                    } else {
                        String msg = response.getString("msg");
                        showAlert(Html.fromHtml(msg).toString());
                    }

                } catch (JSONException ignored) {

                    showAlert(getString(R.string.login_fail));
                }
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers, JSONArray response) {
                showAlert(getString(R.string.login_fail));
            }

            @Override
            public void onFailure(int statusCode, Header[] headers, Throwable throwable, JSONObject errorResponse) {
                showAlert(getString(R.string.login_fail));
            }

            @Override
            public void onFailure(int statusCode, Header[] headers, Throwable throwable, JSONArray errorResponse) {
                showAlert(getString(R.string.login_fail));
            }

            @Override
            public void onFailure(int statusCode, Header[] headers,
                                  String responseString, Throwable throwable) {
                showAlert(getString(R.string.login_fail));
            }
        });
    }


    private void showAlert(String msg) {
        mProgress.dismiss();
        new MaterialDialog.Builder(this)
                .title("QQ登入失败")
                .iconRes(R.drawable.ic_action_alert)
                .positiveText(R.string.ok)
                .content(msg)
                .cancelable(false)
                .callback(new MaterialDialog.ButtonCallback() {
                    @Override
                    public void onPositive(MaterialDialog dialog) {
                        QQActivity.this.finish();
                    }
                })
                .build().show();
    }
}
