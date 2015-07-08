package com.dashang.park;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.provider.Settings;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import com.afollestad.materialdialogs.MaterialDialog;


public class SplashActivity extends ActionBarActivity {
    private static int SPLASH_TIME_OUT = 1000;
    private MaterialDialog alert;
    private boolean isLoggedIn = false;
    private boolean isLaunched = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);

        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(SplashActivity.this);
        String token = prefs.getString("token", "");
        isLoggedIn = !token.equals("");
    }


    @Override
    protected void onResume() {
        super.onResume();
        if (isLoggedIn && !isLaunched) {
            isLaunched = true;
            load();
        } else if (!isOnline()) {
            showAlert();
        } else if (!isLaunched) {
            isLaunched = true;
            load();
        }
    }


    private void load() {
        new Handler().postDelayed(new Runnable() {

            @Override
            public void run() {

                Intent i;
                if (isLoggedIn) {
                    i = new Intent(SplashActivity.this, OptionActivity.class);
                } else {
                    i = new Intent(SplashActivity.this, LoginActivity.class);
                }


                SplashActivity.this.startActivity(i);
                SplashActivity.this.finish();
            }
        }, SPLASH_TIME_OUT);
    }

    private void showAlert() {
        if (alert == null) {
            alert = new MaterialDialog.Builder(this)
                    .title(R.string.no_internet)
                    .items(R.array.network_options)
                    .iconRes(R.drawable.ic_action_wifi)
                    .cancelable(false)
                    .itemsCallback(new MaterialDialog.ListCallback() {
                        @Override
                        public void onSelection(MaterialDialog dialog, View view, int which, CharSequence text) {
                            alert.dismiss();
                            switch (which) {

                                case 0:
                                    SplashActivity.this.startActivity(new Intent(
                                            Settings.ACTION_WIFI_SETTINGS));
                                    break;
                                case 1:
                                    SplashActivity.this.startActivity(new Intent(
                                            Settings.ACTION_WIRELESS_SETTINGS));
                                    break;
                                default:
                                    SplashActivity.this.finish();
                                    break;
                            }
                        }
                    })
                    .build();
        }
        alert.show();
    }

    private boolean isOnline() {
        ConnectivityManager cm = (ConnectivityManager) this
                .getSystemService(Context.CONNECTIVITY_SERVICE);
        return cm.getActiveNetworkInfo() != null
                && cm.getActiveNetworkInfo().isConnectedOrConnecting();
    }


}
