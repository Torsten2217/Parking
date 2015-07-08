package com.dashang.park;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.app.ActionBarActivity;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import com.afollestad.materialdialogs.MaterialDialog;
import com.dashang.park.helper.StringHelper;
import com.dashang.park.model.MarkModel;

import java.text.SimpleDateFormat;
import java.util.Date;


public class OptionActivity extends ActionBarActivity implements View.OnClickListener {
    private View btnContact;
    private View btnPark;
    private View btnFind;
    private TextView txtTime;
    private TextView txtLoc;
    private SharedPreferences.Editor editor;
    private String mPark;
    private MarkModel markModel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_option);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle(R.string.app_name);
        toolbar.setLogo(R.drawable.ic_logo);
        setSupportActionBar(toolbar);

        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        mPark = prefs.getString("park", "");
        String mTime = prefs.getString("time", "- : -");
        editor = prefs.edit();

        btnContact = findViewById(R.id.btn_contact);
        btnPark = findViewById(R.id.btn_park);
        btnFind = findViewById(R.id.btn_find);

        txtTime = (TextView) findViewById(R.id.txt_time);
        txtLoc = (TextView) findViewById(R.id.txt_loc);
        txtTime.setText(mTime);
        txtLoc.setText(StringHelper.getLoc(mPark));

        btnContact.setOnClickListener(this);
        btnPark.setOnClickListener(this);
        btnFind.setOnClickListener(this);

        markModel = new MarkModel();

    }

    @Override
    public void onClick(View v) {
        if (v.equals(btnContact)) {
            Intent intent = new Intent(this, ContactActivity.class);
            this.startActivity(intent);
        } else if (v.equals(btnFind)) {

            if (!TextUtils.isEmpty(mPark)) {
                Intent intent = new Intent(this, ScanActivity.class);
                intent.putExtra("park", false);
                startActivityForResult(intent, 2);
            } else {
                showAlert("错误", "请先停车");
            }


        } else if (v.equals(btnPark)) {
            Intent intent = new Intent(this, ScanActivity.class);
            startActivityForResult(intent, 1);
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

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        switch (requestCode) {
            case 1:
                if (resultCode == Activity.RESULT_OK) {
                    Bundle res = data.getExtras();
                    String loc = res.getString("loc").trim();


                    if (markModel.exist(loc)) {
                        Date now = new Date();
                        SimpleDateFormat sdf = new SimpleDateFormat("hh : mm a");
                        String formattedTime = sdf.format(now);
                        editor.putString("park", loc);
                        editor.putString("time", formattedTime);
                        editor.apply();

                        mPark = loc;
                        txtTime.setText(formattedTime);
                        txtLoc.setText(StringHelper.getLoc(mPark));
                        Intent intent = new Intent(this, ParkActivity.class);
                        startActivity(intent);

                    } else {
                        showAlert("失败", "二维码不存在");
                    }
                }
                break;

            case 2:
                if (resultCode == Activity.RESULT_OK) {
                    Bundle res = data.getExtras();
                    String loc = res.getString("loc").trim();

                    if (loc.equals(mPark)) {
                        showAlert("成功", "您就在停车位");
                    } else if (markModel.exist(loc)) {


                        Intent intent = new Intent(this, MainActivity.class);
                        intent.putExtra("current", loc);
                        intent.putExtra("park", mPark);
                        startActivity(intent);

                    } else {
                        showAlert("失败", "二维码不存在");
                    }
                }
                break;
            default:
                break;
        }
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_share) {
            Intent sendIntent = new Intent();
            sendIntent.setAction(Intent.ACTION_SEND);
            sendIntent.putExtra(Intent.EXTRA_TEXT,
                    "下载郑州大商新玛特金博大店手机软件\n安卓（ARM）: " + StringHelper.ANDROID_ARM + "\n安卓（x86）: " + StringHelper.ANDROID_X86 + "\niOS : " + StringHelper.IOS);
            sendIntent.setType("text/plain");
            startActivity(sendIntent);
            return true;
        } else if (id == R.id.action_logout) {
            Intent intent = new Intent(this, LoginActivity.class);
            editor.remove("token");
            editor.apply();
            this.startActivity(intent);
            this.finish();
            return true;
        } else if (id == R.id.action_account) {
            Intent intent = new Intent(this, AccountActivity.class);
            this.startActivity(intent);
            return true;
        } else if (id == R.id.action_qr) {
            Intent intent = new Intent(this, QrActivity.class);
            this.startActivity(intent);
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
