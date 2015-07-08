package ooi.xalien.qrcode;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Point;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.LinearInterpolator;
import android.view.animation.TranslateAnimation;

public class ViewFinderView extends View {
//    private static final String TAG = "ViewFinderView";

    private Rect mFramingRect;

    private static final int MIN_FRAME_WIDTH = 450;
    private static final int MIN_FRAME_HEIGHT = 450;

//    private static final float LANDSCAPE_WIDTH_RATIO = 5f/8;
//    private static final float LANDSCAPE_HEIGHT_RATIO = 5f/8;
//    private static final int LANDSCAPE_MAX_FRAME_WIDTH = (int) (1920 * LANDSCAPE_WIDTH_RATIO); // = 5/8 * 1920
//    private static final int LANDSCAPE_MAX_FRAME_HEIGHT = (int) (1080 * LANDSCAPE_HEIGHT_RATIO); // = 5/8 * 1080

//    private static final float PORTRAIT_WIDTH_RATIO = 7f/8;
//    private static final float PORTRAIT_HEIGHT_RATIO = 3f/8;
//    private static final int PORTRAIT_MAX_FRAME_WIDTH = (int) (1080 * PORTRAIT_WIDTH_RATIO); // = 7/8 * 1080
//    private static final int PORTRAIT_MAX_FRAME_HEIGHT = (int) (1920 * PORTRAIT_HEIGHT_RATIO); // = 3/8 * 1920

    private static final int[] SCANNER_ALPHA = {0, 64, 128, 192, 255, 192, 128, 64};
    private int scannerAlpha;
    private static final int POINT_SIZE = 10;
    //private static final long ANIMATION_DELAY = 80l;
    private long animationDelay;
    private float mHeight;
    private float mCount;
    private boolean mDown = true;
    private float dp;

    public ViewFinderView(Context context) {
        super(context);
    }

    public ViewFinderView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public void setupViewFinder() {
        updateFramingRect();
        invalidate();
    }

    public Rect getFramingRect() {
        return mFramingRect;
    }

    @Override
    public void onDraw(Canvas canvas) {
        if(mFramingRect == null) {
            return;
        }

        drawViewFinderMask(canvas);
        drawViewFinderBorder(canvas);
        //drawLaser(canvas);
    }

    public void drawViewFinderMask(Canvas canvas) {
        Paint paint = new Paint();
        Resources resources = getResources();
        paint.setColor(resources.getColor(R.color.viewfinder_mask));

        int width = canvas.getWidth();
        int height = canvas.getHeight();

        canvas.drawRect(0, 0, width, mFramingRect.top, paint);
        canvas.drawRect(0, mFramingRect.top, mFramingRect.left, mFramingRect.bottom + 1, paint);
        canvas.drawRect(mFramingRect.right + 1, mFramingRect.top, width, mFramingRect.bottom + 1, paint);
        canvas.drawRect(0, mFramingRect.bottom + 1, width, height, paint);
    }

    public void drawViewFinderBorder(Canvas canvas) {
        Paint paint = new Paint();
        Resources resources = getResources();
        paint.setColor(resources.getColor(R.color.viewfinder_border));
        paint.setStyle(Paint.Style.STROKE);
        paint.setStrokeWidth(5*dp);
        float lineLength = 30*dp;

        float nOffset = 10*dp;
        float tOffset = 12.5f *dp;

        canvas.drawLine(mFramingRect.left - nOffset, mFramingRect.top - tOffset, mFramingRect.left - nOffset, mFramingRect.top - nOffset + lineLength, paint);
        canvas.drawLine(mFramingRect.left - tOffset, mFramingRect.top - nOffset, mFramingRect.left - nOffset + lineLength, mFramingRect.top - nOffset, paint);

        canvas.drawLine(mFramingRect.left - nOffset, mFramingRect.bottom + tOffset, mFramingRect.left - nOffset, mFramingRect.bottom + nOffset - lineLength, paint);
        canvas.drawLine(mFramingRect.left - tOffset, mFramingRect.bottom + nOffset, mFramingRect.left - nOffset + lineLength, mFramingRect.bottom + nOffset, paint);

        canvas.drawLine(mFramingRect.right + nOffset, mFramingRect.top - tOffset, mFramingRect.right + nOffset, mFramingRect.top - nOffset + lineLength, paint);
        canvas.drawLine(mFramingRect.right + tOffset, mFramingRect.top - nOffset, mFramingRect.right + nOffset - lineLength, mFramingRect.top - nOffset, paint);

        canvas.drawLine(mFramingRect.right + nOffset, mFramingRect.bottom + tOffset, mFramingRect.right + nOffset, mFramingRect.bottom + nOffset - lineLength, paint);
        canvas.drawLine(mFramingRect.right + tOffset, mFramingRect.bottom + nOffset, mFramingRect.right + nOffset - lineLength, mFramingRect.bottom + nOffset, paint);
    }

    public void drawLaser(Canvas canvas) {
        Paint paint = new Paint();
        Resources resources = getResources();
        // Draw a red "laser scanner" line through the middle to show decoding is active
        paint.setColor(resources.getColor(R.color.viewfinder_laser));
        //paint.setAlpha(SCANNER_ALPHA[scannerAlpha]);
        paint.setStyle(Paint.Style.FILL);
        //scannerAlpha = (scannerAlpha + 1) % SCANNER_ALPHA.length;


       // int middle = mFramingRect.height() / 2 + mFramingRect.top;

        canvas.drawRect(mFramingRect.left, mFramingRect.top + (mCount*dp) - dp/2, mFramingRect.right, mFramingRect.top +  (mCount*dp) + dp/2, paint);


        if(mDown){
            mCount++;
            if(mCount>=mHeight){
                mDown=false;
                mCount=mHeight;
            }
        }else{
            mCount--;
            if(mCount<=0){
                mDown=true;
                mCount=0;
            }
        }


        postInvalidateDelayed(animationDelay,
                mFramingRect.left - POINT_SIZE,
                mFramingRect.top - POINT_SIZE,
                mFramingRect.right + POINT_SIZE,
                mFramingRect.bottom + POINT_SIZE);
    }

    @Override
    protected void onSizeChanged(int xNew, int yNew, int xOld, int yOld) {
        updateFramingRect();
    }

    public synchronized void updateFramingRect() {

        dp = getResources().getDisplayMetrics().density;
        Point viewResolution = new Point(getWidth(), getHeight());
        if (viewResolution == null) {
            return;
        }
        int width;
        int height;
        //int orientation = DisplayUtils.getScreenOrientation(getContext());

//        if(orientation != Configuration.ORIENTATION_PORTRAIT) {
//            width = findDesiredDimensionInRange(LANDSCAPE_WIDTH_RATIO, viewResolution.x, MIN_FRAME_WIDTH, LANDSCAPE_MAX_FRAME_WIDTH);
//            height = findDesiredDimensionInRange(LANDSCAPE_HEIGHT_RATIO, viewResolution.y, MIN_FRAME_HEIGHT, LANDSCAPE_MAX_FRAME_HEIGHT);
//        } else {
//            width = findDesiredDimensionInRange(PORTRAIT_WIDTH_RATIO, viewResolution.x, MIN_FRAME_WIDTH, PORTRAIT_MAX_FRAME_WIDTH);
//            height = findDesiredDimensionInRange(PORTRAIT_HEIGHT_RATIO, viewResolution.y, MIN_FRAME_HEIGHT, PORTRAIT_MAX_FRAME_HEIGHT);
//        }

        width =(int)(250  * dp);
        height =width;
        mHeight = 250;
        animationDelay =(long) (50/mHeight);
        int leftOffset = (viewResolution.x - width) / 2;

        int topOffset =(int) (50 * dp);
        mFramingRect = new Rect(leftOffset, topOffset, leftOffset + width, topOffset + height);
    }

//    private static int findDesiredDimensionInRange(float ratio, int resolution, int hardMin, int hardMax) {
//        int dim = (int) (ratio * resolution);
//        if (dim < hardMin) {
//            return hardMin;
//        }
//        if (dim > hardMax) {
//            return hardMax;
//        }
//        return dim;
//    }

}
