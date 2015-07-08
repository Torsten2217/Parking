package com.dashang.park;

import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import com.dashang.park.helper.StringHelper;


public class ParkActivity extends ActionBarActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_park);


        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setTitle(R.string.app_name);
        toolbar.setLogo(R.drawable.ic_logo);
        setSupportActionBar(toolbar);


        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        String mPark = prefs.getString("park", "");
        String mTime = prefs.getString("time", "- : -");

        TextView txtTime= (TextView)findViewById(R.id.txt_time);
        TextView txtLoc = (TextView)findViewById(R.id.txt_loc);
        txtTime.setText(mTime);
        txtLoc.setText(StringHelper.getLoc(mPark));

        View btnPark = findViewById(R.id.btn_park);
        btnPark.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ParkActivity.this.finish();
            }
        });
    }
}
