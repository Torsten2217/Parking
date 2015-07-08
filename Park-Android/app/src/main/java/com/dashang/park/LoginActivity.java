package com.dashang.park;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.text.Html;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.TextView;

import com.afollestad.materialdialogs.MaterialDialog;
import com.dashang.park.helper.StringHelper;
import com.dashang.park.server.RestClient;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import com.nispok.snackbar.Snackbar;
import com.nispok.snackbar.SnackbarManager;
import com.nispok.snackbar.enums.SnackbarType;
import com.tencent.mm.sdk.modelmsg.SendAuth;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.dashang.park.wxapi.WXEntryActivity;

import org.apache.http.Header;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class LoginActivity extends ActionBarActivity implements View.OnClickListener {
    private EditText txtPass;
    private EditText txtUser;
    private String mUser;
    private String mPass;
    private View btnLogin;
    private View btnRegister;
    private View btnForgot;
    private View btnQQ;
    private View btnWechat;
    private MaterialDialog mProgress;
    private SharedPreferences.Editor editor;
    private InputMethodManager imm;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle(R.string.app_name);
        toolbar.setLogo(R.drawable.ic_logo);
        setSupportActionBar(toolbar);


        txtPass = (EditText) findViewById(R.id.txt_pass);
        imm = (InputMethodManager) getSystemService(
                Context.INPUT_METHOD_SERVICE);
        txtPass.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int id, KeyEvent keyEvent) {
                if (id == EditorInfo.IME_NULL || id == EditorInfo.IME_ACTION_DONE || id == EditorInfo.IME_ACTION_GO) {
                    attemptLogin();
                    return true;
                }
                return false;
            }
        });

        txtUser = (EditText) findViewById(R.id.txt_user);


        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        editor = prefs.edit();
        mUser = prefs.getString("username", "");
        txtUser.setText(mUser);

        btnLogin = findViewById(R.id.btn_login);
        btnForgot = findViewById(R.id.btn_forgot);
        btnRegister = findViewById(R.id.btn_register);
        btnQQ = findViewById(R.id.btn_qq);
        btnWechat = findViewById(R.id.btn_wechat);

        btnLogin.setOnClickListener(this);
        btnForgot.setOnClickListener(this);
        btnRegister.setOnClickListener(this);
        btnQQ.setOnClickListener(this);
        btnWechat.setOnClickListener(this);
    }


    @Override
    public void onClick(View v) {
        if (v.equals(btnForgot)) {
            attemptForgot();
        } else if (v.equals(btnLogin)) {
            attemptLogin();
        } else if (v.equals(btnRegister)) {
            Intent intent = new Intent(this, RegisterActivity.class);
            this.startActivity(intent);
        } else if (v.equals(btnQQ)) {
            Intent intent = new Intent(this, QQActivity.class);
            this.startActivity(intent);
        } else if(v.equals(btnWechat)){


            showProgress();

            editor.putBoolean("wechat_register", true);
            editor.apply();
            IWXAPI api= WXAPIFactory.createWXAPI(this, StringHelper.WECHAT_APP_ID, true);
            api.registerApp(StringHelper.WECHAT_APP_ID);

            final SendAuth.Req req = new SendAuth.Req();
            req.scope = "snsapi_userinfo";
            req.state = "wechat_auth";
            api.sendReq(req);
            this.finish();


        }
    }

    public void attemptForgot() {
        imm.hideSoftInputFromWindow(txtPass.getWindowToken(), 0);

        // Reset errors.
        txtUser.setError(null);


        // Store values at the time of the login attempt.
        mUser = txtUser.getText().toString().trim();


        boolean cancel = false;
        View focusView = null;

        // Check for a valid email address.
        if (TextUtils.isEmpty(mUser) || mUser.length() < 4) {
            txtUser.setError(getString(R.string.error_field_required));
            focusView = txtUser;
            cancel = true;
        }


        if (cancel) {
            // There was an error; don't attempt login and focus the first
            // form field with an error.
            focusView.requestFocus();
        } else {
            forgot();
        }
    }

    public void attemptLogin() {
        imm.hideSoftInputFromWindow(txtPass.getWindowToken(), 0);

        // Reset errors.
        txtUser.setError(null);
        txtPass.setError(null);


        // Store values at the time of the login attempt.
        mUser = txtUser.getText().toString().trim();
        mPass = txtPass.getText().toString().trim();


        boolean cancel = false;
        View focusView = null;

        // Check for a valid password, if the user entered one.
        if (TextUtils.isEmpty(mPass) || !StringHelper.isPasswordValid(mPass)) {
            txtPass.setError(getString(R.string.error_invalid_password));
            focusView = txtPass;
            cancel = true;
        }

        // Check for a valid email address.
        if (TextUtils.isEmpty(mUser) || mUser.length() < 4) {
            txtUser.setError(getString(R.string.error_field_required));
            focusView = txtUser;
            cancel = true;
        }


        if (cancel) {
            // There was an error; don't attempt login and focus the first
            // form field with an error.
            focusView.requestFocus();
        } else {
            login();
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



    private void forgot() {

        showProgress();


        RequestParams params = new RequestParams();
        params.put("username", mUser);
        RestClient.post("forgot", params, new JsonHttpResponseHandler() {

            @Override
            public void onSuccess(int statusCode, Header[] headers, String responseString) {
                showError(getString(R.string.login_fail));
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers,
                                  JSONObject response) {
                try {
                    int status = response.getInt("status");

                    if (status == 1) {

                        showError("密码已传送到电邮");

                    } else {
                        String msg = response.getString("msg");
                        showError(Html.fromHtml(msg).toString());
                    }

                } catch (JSONException ignored) {
                    showError(getString(R.string.login_fail));
                }
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers, JSONArray response) {
                showError(getString(R.string.login_fail));
            }

            @Override
            public void onFailure(int statusCode, Header[] headers, Throwable throwable, JSONObject errorResponse) {
                showError(getString(R.string.login_fail));
            }

            @Override
            public void onFailure(int statusCode, Header[] headers, Throwable throwable, JSONArray errorResponse) {
                showError(getString(R.string.login_fail));
            }

            @Override
            public void onFailure(int statusCode, Header[] headers,
                                  String responseString, Throwable throwable) {
                //showError(responseString);
                showError(getString(R.string.login_fail));
            }
        });
    }

    private void login() {

        showProgress();


        RequestParams params = new RequestParams();
        params.put("username", mUser);
        params.put("password", mPass);
        RestClient.post("login", params, new JsonHttpResponseHandler() {

            @Override
            public void onSuccess(int statusCode, Header[] headers, String responseString) {
                showError(getString(R.string.login_fail));
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers,
                                  JSONObject response) {
                try {
                    int status = response.getInt("status");

                    if (status == 1) {
                        String token = response.getString("token");
                        editor.putString("token", token);
                        editor.putString("username", mUser);

                        editor.apply();
                        Intent intent = new Intent(LoginActivity.this, OptionActivity.class);
                        LoginActivity.this.startActivity(intent);
                        LoginActivity.this.finish();

                    } else {
                        String msg = response.getString("msg");
                        showError(Html.fromHtml(msg).toString());
                    }

                } catch (JSONException ignored) {
                    showError(getString(R.string.login_fail));
                }
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers, JSONArray response) {
                showError(getString(R.string.login_fail));
            }

            @Override
            public void onFailure(int statusCode, Header[] headers, Throwable throwable, JSONObject errorResponse) {
                showError(getString(R.string.login_fail));
            }

            @Override
            public void onFailure(int statusCode, Header[] headers, Throwable throwable, JSONArray errorResponse) {
                showError(getString(R.string.login_fail));
            }

            @Override
            public void onFailure(int statusCode, Header[] headers,
                                  String responseString, Throwable throwable) {
                showError(getString(R.string.login_fail));
            }
        });
    }

    private void showError(String msg) {
        mProgress.dismiss();
        SnackbarManager.show(
                Snackbar.with(getApplicationContext())
                        .text(msg)
                        .duration(Snackbar.SnackbarDuration.LENGTH_INDEFINITE)
                        .actionLabel(getString(R.string.ok))
                , this);
    }
}
