package com.dashang.park;


import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.google.zxing.Result;

import ooi.xalien.qrcode.BeepManager;
import ooi.xalien.qrcode.ZXingScannerView;


public class ScanFragment extends android.support.v4.app.Fragment implements
        ZXingScannerView.ResultHandler {

    private ZXingScannerView mScannerView;
    private BeepManager beepManager;


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle state) {
        mScannerView = new ZXingScannerView(getActivity());
        beepManager = new BeepManager(getActivity());
        return mScannerView;
    }


    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
    }

    @Override
    public void onCreate(Bundle state) {
        super.onCreate(state);
    }


    @Override
    public void onResume() {
        super.onResume();
        restart(true);
    }

    public void setFlash(boolean state) {
        mScannerView.setFlash(state);
    }

    private void restart(boolean state) {
        if (state) {
            mScannerView.setResultHandler(this);
            mScannerView.startCamera();
            mScannerView.setFlash(false);
            mScannerView.setAutoFocus(true);
            beepManager.updatePrefs();
        } else {
            beepManager.close();
            mScannerView.stopCamera();
        }
    }


    @Override
    public void handleResult(Result rawResult) {
        if(isAdded()) {
            ScanActivity mActivity = (ScanActivity)this.getActivity();
            mActivity.stopAnimate();

            beepManager.playBeepSound();
            Bundle conData = new Bundle();
            conData.putString("loc", rawResult.getText());

            Intent intent = new Intent();
            intent.putExtras(conData);
            mActivity.setResult(Activity.RESULT_OK, intent);
            mActivity.finish();
        }
    }


    @Override
    public void onPause() {
        super.onPause();
        restart(false);
    }
}

