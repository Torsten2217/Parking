package com.dashang.park;

import android.app.Activity;
import android.content.Intent;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.support.v7.widget.Toolbar;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.RotateAnimation;
import android.widget.ImageView;

import com.afollestad.materialdialogs.MaterialDialog;
import com.dashang.park.model.MarkModel;

import org.xwalk.core.JavascriptInterface;
import org.xwalk.core.XWalkResourceClient;
import org.xwalk.core.XWalkView;


public class MainActivity extends ActionBarActivity implements SensorEventListener {

    private XWalkView webView;
    private MarkModel markModel;

    private boolean isLoad = true;

    private SensorManager mSensorManager;
    private Sensor mAccelerometer;
    private Sensor mMagnetometer;
    private float[] mLastAccelerometer = new float[3];
    private float[] mLastMagnetometer = new float[3];
    private boolean mLastAccelerometerSet = false;
    private boolean mLastMagnetometerSet = false;
    private float[] mR = new float[9];
    private float[] mOrientation = new float[3];
    private float mCurrentDegree = 0f;

    private String mCurrent;
    private String mPark;
    private MaterialDialog mProgress;
    private int mState;
    private String mPoint;
    private boolean isRotate = false;
    private ImageView btnRotate;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle(R.string.app_name);
        toolbar.setLogo(R.drawable.ic_logo);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setHomeButtonEnabled(true);

        mCurrent = this.getIntent().getStringExtra("current");
        mPark = this.getIntent().getStringExtra("park");


        webView = (XWalkView) findViewById(R.id.webView);
        View btn = findViewById(R.id.button);

        webView.setBackgroundColor(getResources().getColor(R.color.web));
        webView.setHorizontalScrollBarEnabled(false);
        webView.setVerticalScrollBarEnabled(false);




        webView.setResourceClient(new XWalkResourceClient(webView) {
            @Override
            public void onLoadFinished(XWalkView view, String url) {
                super.onLoadFinished(view, url);
                if (url.startsWith("file:///android_asset/")) {
                    mProgress.dismiss();
                    if (mState == 1) {
                        webView.load("javascript:drawMap('" + mCurrent + "', '" + mPark + "')", null);
                    } else if (mState == 2) {
                        webView.load("javascript:drawFrom('" + mCurrent + "')", null);
                    } else if (mState == 3) {
                        webView.load("javascript:drawTo('" + mPoint + "', '" + mPark + "')", null);
                    }
                    isLoad = true;
                }
            }
        });

        mSensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
        mAccelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        mMagnetometer = mSensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD);

        webView.addJavascriptInterface(new MapInterface(), "Android");


        btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MainActivity.this, ScanActivity.class);
                intent.putExtra("park", false);
                MainActivity.this.startActivityForResult(intent, 2);
            }
        });

        markModel = new MarkModel();


        btnRotate = (ImageView) findViewById(R.id.btn_rotate);
        btnRotate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isRotate = !isRotate;

                btnRotate.setImageDrawable(isRotate ?
                        MainActivity.this.getResources().getDrawable(R.drawable.ic_compass_selected)
                        : MainActivity.this.getResources().getDrawable(R.drawable.ic_compass));
                runListener(isRotate);

                if(!isRotate){
                    webView.load("javascript:rotateMap(0)", null);
                    RotateAnimation ra = new RotateAnimation(
                            mCurrentDegree, 0,
                            Animation.RELATIVE_TO_SELF, 0.5f,
                            Animation.RELATIVE_TO_SELF, 0.5f);
                    ra.setDuration(210);
                    ra.setFillAfter(true);
                    btnRotate.startAnimation(ra);
                    mCurrentDegree = 0;
                }
            }
        });

        setup();
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

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        switch (requestCode) {

            case 2:
                if (resultCode == Activity.RESULT_OK) {
                    Bundle res = data.getExtras();
                    String loc = res.getString("loc").trim();

                    if (loc.equals(mPark)) {
                        showAlert("成功", "您就在停车位");
                    } else if (markModel.exist(loc)) {
                        mCurrent = loc;
                        setup();
                    } else {
                        showAlert("失败", "二维码不存在");
                    }
                }
                break;
            default:
                break;
        }
    }

    private void showAlert(String title, String msg) {
        new MaterialDialog.Builder(this)
                .iconRes(R.drawable.ic_action_alert)
                .positiveText(R.string.ok)
                .title(title)
                .content(msg)
                .cancelable(false)
                .build().show();
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

    private void setup() {
        showProgress();
        mCurrentDegree = 0;
        if (mPark.startsWith("L2") && mCurrent.startsWith("L3")) {
            mState = 2;
        } else if (mPark.startsWith("L3") && mCurrent.startsWith("L2")) {
            mState = 2;
        } else {
            mState = 1;
        }

        if (mCurrent.startsWith("L2")) {
            webView.load("file:///android_asset/map1.html", null);
        } else if (mCurrent.startsWith("L3")) {
            webView.load("file:///android_asset/map2.html", null);
        }
    }


    @Override
    protected void onResume() {
        super.onResume();

        runListener(true);
    }

    @Override
    protected void onPause() {
        super.onPause();
        runListener(false);
    }

    private void runListener(boolean state) {
        if (state && isRotate) {
            mSensorManager.registerListener(this, mAccelerometer, SensorManager.SENSOR_DELAY_UI);
            mSensorManager.registerListener(this, mMagnetometer, SensorManager.SENSOR_DELAY_UI);
        } else {
            mSensorManager.unregisterListener(this, mAccelerometer);
            mSensorManager.unregisterListener(this, mMagnetometer);
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {

        if ((keyCode == KeyEvent.KEYCODE_BACK)) { //stop your music here
            MainActivity.this.finish();
            return true;
        } else {
            return super.onKeyDown(keyCode, event);
        }
    }

    @Override
    public void onSensorChanged(SensorEvent event) {
        if (isLoad && isRotate) {

            if (event.sensor == mAccelerometer) {
                System.arraycopy(event.values, 0, mLastAccelerometer, 0, event.values.length);
                mLastAccelerometerSet = true;
            } else if (event.sensor == mMagnetometer) {
                System.arraycopy(event.values, 0, mLastMagnetometer, 0, event.values.length);
                mLastMagnetometerSet = true;
            }
            if (mLastAccelerometerSet && mLastMagnetometerSet) {
                boolean success = SensorManager.getRotationMatrix(mR, null, mLastAccelerometer, mLastMagnetometer);
                if (success) {
                    SensorManager.getOrientation(mR, mOrientation);
                    float azimuthInRadians = mOrientation[0];
                    float azimuthInDegress = (float) (Math.toDegrees(azimuthInRadians) + 360) % 360;

                    float rotation = 360 - azimuthInDegress;
                    float diff = mCurrentDegree - rotation;
                    if (diff > 2 || diff < -2) {
                        webView.load("javascript:rotateMap(" + rotation + ")", null);
                        RotateAnimation ra = new RotateAnimation(
                                mCurrentDegree, rotation,
                                Animation.RELATIVE_TO_SELF, 0.5f,
                                Animation.RELATIVE_TO_SELF, 0.5f);
                        ra.setDuration(210);
                        ra.setFillAfter(true);
                        btnRotate.startAnimation(ra);

                        mCurrentDegree = rotation;
                    }
                }
            }
        }


    }


    public class MapInterface {


        @JavascriptInterface
        public void change(final String point) {

            MainActivity.this.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    isLoad = false;
                    showProgress();
                    mCurrentDegree = 0;
                    mState = 3;

                    mPoint = point;

                    if (mCurrent.startsWith("L2")) {
                        webView.load("file:///android_asset/map2.html", null);
                    } else if (mCurrent.startsWith("L3")) {
                        webView.load("file:///android_asset/map1.html", null);
                    }
                }
            });
        }
    }

}
