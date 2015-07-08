package com.dashang.park;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.AnimationSet;
import android.view.animation.LinearInterpolator;
import android.view.animation.TranslateAnimation;
import android.widget.Button;
import android.widget.TextView;


public class ScanActivity extends ActionBarActivity {
    private boolean mFlash;
    private View mScanner;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_scan);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle(R.string.app_name);
        toolbar.setLogo(R.drawable.ic_logo);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setHomeButtonEnabled(true);

        mScanner = findViewById(R.id.laser);



        float dps = 250;
        float pxs = dps * getResources().getDisplayMetrics().density;
        TranslateAnimation translateAnim = new TranslateAnimation(0, 0, 0, pxs);
        translateAnim.setDuration(2000);
        translateAnim.setRepeatCount(Animation.INFINITE);
        translateAnim.setRepeatMode(Animation.REVERSE);
        translateAnim.setInterpolator(new LinearInterpolator());


        mScanner.startAnimation(translateAnim);


        if (!this.getIntent().getBooleanExtra("park", true)) {

            TextView txt = (TextView) findViewById(R.id.txt);
            txt.setText("扫描身边的二维码确定你的位置");
        }


        final ScanFragment fragment = (ScanFragment) getSupportFragmentManager().findFragmentById(R.id.scanner_fragment);

        final View btnFlash = findViewById(R.id.btn_flash);
        btnFlash.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mFlash = !mFlash;
                btnFlash.setSelected(mFlash);
                fragment.setFlash(mFlash);
            }
        });

    }


    public void stopAnimate(){
        mScanner.clearAnimation();
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
}
