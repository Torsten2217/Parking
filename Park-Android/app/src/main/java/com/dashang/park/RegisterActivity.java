package com.dashang.park;

import android.content.Context;
import android.content.Intent;
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
import com.nispok.snackbar.listeners.ActionClickListener;

import org.apache.http.Header;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


public class RegisterActivity extends ActionBarActivity {

    private EditText txtPass;
    private EditText txtUser;
    private EditText txtName;
    private EditText txtEmail;
    private EditText txtPhone;
    private EditText txtConfirm;
    private String mUser;
    private String mPass;
    private String mName;
    private String mEmail;
    private String mPhone;
    private String mConfirm;

    private View btnRegister;
    private InputMethodManager imm;
    private MaterialDialog mProgress;
    private boolean isSuccess = false;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle(R.string.app_name);
        toolbar.setLogo(R.drawable.ic_logo);
        setSupportActionBar(toolbar);


        //mQQ = this.getIntent().getStringExtra("qq");

        txtName = (EditText) findViewById(R.id.txt_name);
        txtPhone = (EditText) findViewById(R.id.txt_phone);
        txtEmail = (EditText) findViewById(R.id.txt_email);

        txtUser = (EditText) findViewById(R.id.txt_user);
        txtPass = (EditText) findViewById(R.id.txt_pass);

        txtConfirm = (EditText) findViewById(R.id.txt_confirm);


        imm = (InputMethodManager) getSystemService(
                Context.INPUT_METHOD_SERVICE);
        txtConfirm.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int id, KeyEvent keyEvent) {
                if (id == EditorInfo.IME_NULL || id == EditorInfo.IME_ACTION_DONE || id == EditorInfo.IME_ACTION_GO) {
                    attemptRegister();
                    return true;
                }
                return false;
            }
        });


        btnRegister = findViewById(R.id.btn_register);
        btnRegister.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                attemptRegister();
            }
        });
    }

    private void showProgress() {
        if (mProgress == null) {
            mProgress = new MaterialDialog.Builder(this)
                    .content("注册中……")
                    .cancelable(false)
                    .progress(true, 0)
                    .build();
        }
        mProgress.show();
    }

    public void attemptRegister() {
        imm.hideSoftInputFromWindow(txtPass.getWindowToken(), 0);

        // Reset errors.
        txtUser.setError(null);
        txtPass.setError(null);
        txtConfirm.setError(null);
        txtName.setError(null);
        txtPhone.setError(null);
        txtEmail.setError(null);


        // Store values at the time of the login attempt.
        mUser = txtUser.getText().toString().trim();
        mPass = txtPass.getText().toString().trim();
        mConfirm = txtConfirm.getText().toString().trim();
        mName = txtName.getText().toString().trim();
        mPhone = txtPhone.getText().toString().trim();
        mEmail = txtEmail.getText().toString().trim();


        boolean cancel = false;
        View focusView = null;


        if (!mConfirm.equals(mPass)) {
            txtConfirm.setError("密码不符合");
            focusView = txtConfirm;
            cancel = true;
        }


        // Check for a valid password, if the user entered one.
        if (TextUtils.isEmpty(mPass) || !StringHelper.isPasswordValid(mPass)) {
            txtPass.setError(getString(R.string.error_invalid_password));
            focusView = txtPass;
            cancel = true;
        }

        if (TextUtils.isEmpty(mUser) || mUser.length() < 2) {
            txtUser.setError(getString(R.string.error_field_required));
            focusView = txtUser;
            cancel = true;
        }


        if (TextUtils.isEmpty(mPhone)) {
            txtPhone.setError(getString(R.string.error_field_required));
            focusView = txtPhone;
            cancel = true;
        }

        if (!StringHelper.isPhoneValid(mPhone)) {
            txtPhone.setError("电话号码格式错误，请填数字而已");
            focusView = txtPhone;
            cancel = true;
        }

        if (TextUtils.isEmpty(mEmail)) {
            txtEmail.setError(getString(R.string.error_field_required));
            focusView = txtEmail;
            cancel = true;
        }

        if (!StringHelper.isEmailValid(mEmail)) {
            txtEmail.setError("电邮格式错误");
            focusView = txtEmail;
            cancel = true;
        }


        if (TextUtils.isEmpty(mName) || mName.length() < 2) {
            txtName.setError(getString(R.string.error_field_required));
            focusView = txtName;
            cancel = true;
        }


        if (cancel) {
            // There was an error; don't attempt login and focus the first
            // form field with an error.
            focusView.requestFocus();
        } else {
            register();
        }
    }


    private void register() {

        showProgress();


        RequestParams params = new RequestParams();
        params.put("username", mUser);
        params.put("password", mPass);
        params.put("name", mName);
        params.put("phone", mPhone);
        params.put("email", mEmail);

        RestClient.post("register", params, new JsonHttpResponseHandler() {

            @Override
            public void onSuccess(int statusCode, Header[] headers, String responseString) {
                showError(getString(R.string.login_fail));
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers,
                                  JSONObject response) {
                try {
                    int status = response.getInt("status");
                    String msg = response.getString("msg");
                    if (status == 1) {
                        isSuccess = true;

                    }


                    showError(Html.fromHtml(msg).toString());


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
                        .actionListener(new ActionClickListener() {
                            @Override
                            public void onActionClicked(Snackbar snackbar) {
                                if (isSuccess) {
                                    RegisterActivity.this.finish();
                                }
                            }
                        })
                , this);
    }
}
