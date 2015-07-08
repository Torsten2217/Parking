package ooi.xalien.qrcode;

import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.hardware.Camera;
import android.os.AsyncTask;
import android.support.v4.app.Fragment;
import android.util.AttributeSet;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.DecodeHintType;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.PlanarYUVLuminanceSource;
import com.google.zxing.ReaderException;
import com.google.zxing.Result;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.qrcode.QRCodeReader;

import java.util.ArrayList;
import java.util.Collection;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

import static android.hardware.Camera.*;


public class ZXingScannerView extends BarcodeScannerView {
    public interface ResultHandler {
        public void handleResult(Result rawResult);
    }

    private QRCodeReader mMultiFormatReader;
    private ResultHandler mResultHandler;
    private boolean isStop = false;


    public ZXingScannerView(Context context) {
        super(context);
        initMultiFormatReader();
    }

    public ZXingScannerView(Context context, AttributeSet attributeSet) {
        super(context, attributeSet);
        initMultiFormatReader();
    }

//    public void setFormats(List<BarcodeFormat> formats) {
//        mFormats = formats;
//        initMultiFormatReader();
//    }

    public void setResultHandler(ResultHandler resultHandler) {
        mResultHandler = resultHandler;
    }


    private void initMultiFormatReader() {

        mMultiFormatReader = new QRCodeReader();
    }

    @Override
    public void onPreviewFrame(final byte[] data, final Camera camera) {

        new AsyncTask<Void, Void, Void>() {
            Result rawResult;

            @Override
            protected Void doInBackground(Void... urls) {
                Camera.Parameters parameters = camera.getParameters();
                Camera.Size size = parameters.getPreviewSize();
                int width = size.width;
                int height = size.height;


                byte[] rotatedData = new byte[data.length];
                for (int y = 0; y < height; y++) {
                    for (int x = 0; x < width; x++)
                        rotatedData[x * height + height - y - 1] = data[x + y * width];
                }
                int tmp = width;
                width = height;
                height = tmp;


                rawResult = null;
                PlanarYUVLuminanceSource source = buildLuminanceSource(rotatedData, width, height);

                if (source != null) {
                    BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));
                    try {
                        rawResult = mMultiFormatReader.decode(bitmap);
                    } catch (ReaderException | NullPointerException | ArrayIndexOutOfBoundsException re) {
                        // continue
                    } finally {
                        mMultiFormatReader.reset();
                    }
                }

                return null;
            }

            @Override
            protected void onPostExecute(Void param) {
                if (rawResult != null) {
                    isStop = true;
                    stopCamera();
                    if (mResultHandler != null) {
                        mResultHandler.handleResult(rawResult);
                    }
                } else if (!isStop) {
                    try {
                        camera.setOneShotPreviewCallback(ZXingScannerView.this);
                    }catch(Exception ignored){

                    }
                }
            }
        }.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    }

    public PlanarYUVLuminanceSource buildLuminanceSource(byte[] data, int width, int height) {
        Rect rect = getFramingRectInPreview(width, height);
        if (rect == null) {
            return null;
        }
        // Go ahead and assume it's YUV rather than die.
        PlanarYUVLuminanceSource source = null;

        try {
            source = new PlanarYUVLuminanceSource(data, width, height, rect.left, rect.top,
                    rect.width(), rect.height(), false);
        } catch (Exception ignored) {
        }

        return source;
    }
}