package com.dashang.park.wxapi;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.app.ActionBarActivity;
import android.support.v7.widget.Toolbar;
import android.text.Html;
import android.util.Log;

import com.afollestad.materialdialogs.MaterialDialog;
import com.dashang.park.AccountActivity;
import com.dashang.park.LoginActivity;
import com.dashang.park.OptionActivity;
import com.dashang.park.R;
import com.dashang.park.helper.StringHelper;
import com.dashang.park.server.RestClient;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import com.tencent.mm.sdk.constants.ConstantsAPI;
import com.tencent.mm.sdk.modelbase.BaseReq;
import com.tencent.mm.sdk.modelbase.BaseResp;
import com.tencent.mm.sdk.modelmsg.SendAuth;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import org.apache.http.Header;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class WXEntryActivity extends ActionBarActivity implements IWXAPIEventHandler {
    private IWXAPI api;
    private MaterialDialog mProgress;
    private boolean isRegister;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_wxentry);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle(R.string.app_name);
        toolbar.setLogo(R.drawable.ic_logo);
        setSupportActionBar(toolbar);

        showProgress();
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        isRegister = prefs.getBoolean("wechat_register", true);
        api = WXAPIFactory.createWXAPI(this, StringHelper.WECHAT_APP_ID);


        api.handleIntent(getIntent(), this);
    }

    @Override
    public void onResp(BaseResp resp) {
        //Log.i(WXEntryActivity.class.getName(), resp.toString());
        int result;
        switch (resp.errCode) {
            case BaseResp.ErrCode.ERR_OK:
                switch (resp.getType()) {
                    case ConstantsAPI.COMMAND_SENDAUTH:
                        auth(resp);
                        return;
                    default:
                        result = R.string.errcode_success;
                        break;
                }
                break;
            case BaseResp.ErrCode.ERR_USER_CANCEL:
                result = R.string.errcode_cancel;
                break;
            case BaseResp.ErrCode.ERR_AUTH_DENIED:
                result = R.string.errcode_deny;
                break;
            default:
                result = R.string.errcode_unknown;
                break;
        }

        showAlert(this.getString(result));

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

    private void auth(BaseResp resp) {
        SendAuth.Resp res = ((SendAuth.Resp) resp);
        getOpenId(res.code);
    }

    private void getOpenId(String code) {
        String url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=" + StringHelper.WECHAT_APP_ID;
        url += "&secret=" + StringHelper.WECHAT_SECRET;
        url += "&code=" + code;
        url += "&grant_type=authorization_code";
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

                    String accessToken = response.getString("access_token");
                    String openId = response.getString("openid");

                    getUsername(openId, accessToken);

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


    private void getUsername(final String openId, String accessToken) {

        String url = "https://api.weixin.qq.com/sns/userinfo?access_token=" + accessToken;
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


                    String username = response.getString("nickname");


                    register(openId, username);


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


    private void register(String openId, String nickname) {

        RequestParams params = new RequestParams();
        params.put("wechat", openId);
        params.put("username", nickname);
        if (!isRegister) {
            SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(WXEntryActivity.this);
            params.put("token", prefs.getString("token", ""));
        }

        RestClient.post(isRegister ? "register" : "connect", params, new JsonHttpResponseHandler() {

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
                        if (isRegister) {
                            SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(WXEntryActivity.this);
                            SharedPreferences.Editor editor = prefs.edit();
                            String token = response.getString("token");
                            editor.putString("token", token);

                            editor.apply();

                            Intent intent = new Intent(WXEntryActivity.this, OptionActivity.class);
                            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                            mProgress.dismiss();
                            WXEntryActivity.this.startActivity(intent);
                            WXEntryActivity.this.finish();
                        } else {
                            Intent intent = new Intent(WXEntryActivity.this, AccountActivity.class);
                            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                            mProgress.dismiss();
                            WXEntryActivity.this.startActivity(intent);
                            WXEntryActivity.this.finish();

                        }

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
                .title("微信登入失败")
                .iconRes(R.drawable.ic_action_alert)
                .positiveText(R.string.ok)
                .content(msg)
                .cancelable(false)
                .callback(new MaterialDialog.ButtonCallback() {
                    @Override
                    public void onPositive(MaterialDialog dialog) {

                        Intent intent = new Intent(WXEntryActivity.this, isRegister ? LoginActivity.class : AccountActivity.class);
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                        WXEntryActivity.this.startActivity(intent);
                        WXEntryActivity.this.finish();

                    }
                })
                .build().show();
    }

    @Override
    public void onReq(BaseReq req) {
        finish();
    }
}