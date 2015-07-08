package com.dashang.park;

import android.graphics.Bitmap;
import android.os.AsyncTask;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ImageView;

import com.afollestad.materialdialogs.MaterialDialog;
import com.dashang.park.helper.StringHelper;

import net.glxn.qrgen.android.QRCode;


public class QrActivity extends ActionBarActivity {
    private ImageView myImage1;
    private ImageView myImage2;
    private ImageView myImage3;
    private MaterialDialog mProgress;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_qr);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle("分享二维码");
        toolbar.setLogo(R.drawable.ic_logo);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setHomeButtonEnabled(true);

        myImage1 = (ImageView) findViewById(R.id.imageView1);
        myImage2 = (ImageView) findViewById(R.id.imageView2);
        myImage3 = (ImageView) findViewById(R.id.imageView3);

        new AsyncTask<Void, Void, Void>() {
            Bitmap bmp1;
            Bitmap bmp2;
            Bitmap bmp3;

            @Override
            protected void onPreExecute() {
                showProgress();
            }

            @Override
            protected Void doInBackground(Void... params) {


                bmp1 = QRCode.from(StringHelper.ANDROID_ARM).bitmap();
                bmp2 = QRCode.from(StringHelper.ANDROID_X86).bitmap();
                bmp3 = QRCode.from(StringHelper.IOS).bitmap();
                return null;
            }


            @Override
            protected void onPostExecute(Void params) {
                myImage1.setImageBitmap(bmp1);
                myImage2.setImageBitmap(bmp2);
                myImage3.setImageBitmap(bmp3);
                mProgress.dismiss();
            }
        }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
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
