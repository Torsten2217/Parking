package com.dashang.park;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.support.v4.app.NavUtils;
import android.support.v4.app.TaskStackBuilder;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.support.v7.widget.SwitchCompat;
import android.support.v7.widget.Toolbar;
import android.text.Html;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.content.Intent;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.CompoundButton;
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
import com.tencent.mm.sdk.modelmsg.SendAuth;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;

import org.apache.http.Header;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


public class AccountActivity extends ActionBarActivity implements View.OnClickListener,CompoundButton.OnCheckedChangeListener {

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

    private String mToken;

    private View btnUpdate;
    private View btnAccount;

    private SwitchCompat switchWechat;
    private SwitchCompat switchQQ;

    private InputMethodManager imm;
    private MaterialDialog mProgress;
    private SharedPreferences prefs;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_account);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle(R.string.app_name);
        toolbar.setLogo(R.drawable.ic_logo);
        setSupportActionBar(toolbar);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setHomeButtonEnabled(true);

        txtName = (EditText) findViewById(R.id.txt_name);
        txtPhone = (EditText) findViewById(R.id.txt_phone);
        txtEmail = (EditText) findViewById(R.id.txt_email);

        txtUser = (EditText) findViewById(R.id.txt_user);
        txtPass = (EditText) findViewById(R.id.txt_pass);

        txtConfirm = (EditText) findViewById(R.id.txt_confirm);


        switchQQ = (SwitchCompat)findViewById(R.id.switchQQ);
        switchWechat = (SwitchCompat)findViewById(R.id.switchWechat);




        imm = (InputMethodManager) getSystemService(
                Context.INPUT_METHOD_SERVICE);
        txtConfirm.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int id, KeyEvent keyEvent) {
                if (id == EditorInfo.IME_NULL || id == EditorInfo.IME_ACTION_DONE || id == EditorInfo.IME_ACTION_GO) {
                    attemptAccount();
                    return true;
                }
                return false;
            }
        });

        txtPhone.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int id, KeyEvent keyEvent) {
                if (id == EditorInfo.IME_NULL || id == EditorInfo.IME_ACTION_DONE || id == EditorInfo.IME_ACTION_GO) {
                    attemptUpdate();
                    return true;
                }
                return false;
            }
        });
        btnUpdate = findViewById(R.id.btn_update);
        btnAccount = findViewById(R.id.btn_account);

        btnAccount.setOnClickListener(this);
        btnUpdate.setOnClickListener(this);

        prefs = PreferenceManager.getDefaultSharedPreferences(this);
        mToken = prefs.getString("token", "");

        getAccount();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            // Respond to the action bar's Up/Home button
            case android.R.id.home:
                navigateUp();
                return true;
        }
        return super.onOptionsItemSelected(item);
    }


    private void navigateUp(){
        Intent upIntent = NavUtils.getParentActivityIntent(this);
        if (NavUtils.shouldUpRecreateTask(this, upIntent)) {
            // This activity is NOT part of this app's task, so create a new task
            // when navigating up, with a synthesized back stack.
            TaskStackBuilder.create(this)
                    // Add all of this activity's parents to the back stack
                    .addNextIntentWithParentStack(upIntent)
                            // Navigate up to the closest parent
                    .startActivities();
        } else {
            // This activity is part of this app's task, so simply
            // navigate up to the logical parent activity.
            NavUtils.navigateUpTo(this, upIntent);
        }
    }

    private void getAccount() {
        showProgress();


        RequestParams params = new RequestParams();
        params.put("token", mToken);
        RestClient.post("account", params, new JsonHttpResponseHandler() {

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

                        JSONObject result = response.getJSONObject("result");
                        if (!result.isNull("name")) {
                            mName = result.getString("name");
                            txtName.setText(mName);
                        }

                        if (!result.isNull("username")) {
                            mUser = result.getString("username");
                            txtUser.setText(mUser);
                        }
                        if (!result.isNull("email")) {
                            mEmail = result.getString("email");
                            txtEmail.setText(mEmail);
                        }

                        if (!result.isNull("phone")) {
                            mPhone = result.getString("phone");
                            txtPhone.setText(mPhone);
                        }

                        if (!result.isNull("qq_id")) {
                            switchQQ.setChecked(true);
                            switchQQ.setClickable(false);
                        }


                        if (!result.isNull("wechat_id")) {
                            switchWechat.setChecked(true);
                            switchWechat.setClickable(false);
                        }


                        switchQQ.setOnCheckedChangeListener(AccountActivity.this);
                        switchWechat.setOnCheckedChangeListener(AccountActivity.this);
                        mProgress.dismiss();

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
                        AccountActivity.this.finish();
                    }
                })
                .build().show();
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
                            }
                        })
                , this);
    }

    private void attemptUpdate() {

        imm.hideSoftInputFromWindow(txtPass.getWindowToken(), 0);


        txtName.setError(null);
        txtPhone.setError(null);
        txtEmail.setError(null);


        mName = txtName.getText().toString().trim();
        mPhone = txtPhone.getText().toString().trim();
        mEmail = txtEmail.getText().toString().trim();


        boolean cancel = false;
        View focusView = null;


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
            update();
        }
    }


    private void update() {

        showProgress();
        RequestParams params = new RequestParams();
        params.put("name", mName);
        params.put("phone", mPhone);
        params.put("email", mEmail);
        params.put("token", mToken);
        post(params);
    }

    private void account() {

        showProgress();
        RequestParams params = new RequestParams();
        params.put("username", mUser);
        params.put("password", mPass);
        params.put("token", mToken);
        post(params);
    }

    private void post(RequestParams params) {
        RestClient.post("update", params, new JsonHttpResponseHandler() {

            @Override
            public void onSuccess(int statusCode, Header[] headers, String responseString) {
                showError(getString(R.string.login_fail));
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers,
                                  JSONObject response) {
                try {
                    String msg = response.getString("msg");
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

    private void attemptAccount() {
        imm.hideSoftInputFromWindow(txtPass.getWindowToken(), 0);

        // Reset errors.
        txtUser.setError(null);
        txtPass.setError(null);
        txtConfirm.setError(null);


        // Store values at the time of the login attempt.
        mUser = txtUser.getText().toString().trim();
        mPass = txtPass.getText().toString().trim();
        String mConfirm = txtConfirm.getText().toString().trim();


        boolean cancel = false;
        View focusView = null;


        if (!mConfirm.equals(mPass)) {
            txtConfirm.setError("密码不符合");
            focusView = txtConfirm;
            cancel = true;
        }


        // Check for a valid password, if the user entered one.
        if (!TextUtils.isEmpty(mPass) && !StringHelper.isPasswordValid(mPass)) {
            txtPass.setError(getString(R.string.error_invalid_password));
            focusView = txtPass;
            cancel = true;
        }

        if (TextUtils.isEmpty(mUser) || mUser.length() < 2) {
            txtUser.setError(getString(R.string.error_field_required));
            focusView = txtUser;
            cancel = true;
        }


        if (cancel) {
            // There was an error; don't attempt login and focus the first
            // form field with an error.
            focusView.requestFocus();
        } else {
            account();
        }
    }

    @Override
    public void onBackPressed() {
        navigateUp();
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

    @Override
    public void onClick(View v) {
        if (v.equals(btnAccount)) {
            attemptAccount();
        } else if (v.equals(btnUpdate)) {
            attemptUpdate();
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        switch (requestCode) {

            case 1:
                if (resultCode == Activity.RESULT_OK) {
                    switchQQ.setClickable(false);
                }else{
                    switchQQ.setChecked(false);
                }
                break;
            default:
                break;
        }
    }

    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        if(buttonView.equals(switchQQ)&& isChecked){
            Intent intent = new Intent(this, ConnectQQActivity.class);
            this.startActivityForResult(intent, 1);
        }else if(buttonView.equals(switchWechat)&& isChecked){
            showProgress();
            SharedPreferences.Editor editor = prefs.edit();
            editor.putBoolean("wechat_register", false);
            editor.apply();

            IWXAPI api = WXAPIFactory.createWXAPI(this, StringHelper.WECHAT_APP_ID);
            api.registerApp(StringHelper.WECHAT_APP_ID);

            final SendAuth.Req req = new SendAuth.Req();
            req.scope = "snsapi_userinfo";
            req.state = "wechat_connect";
            api.sendReq(req);
            this.finish();
        }
    }
}
