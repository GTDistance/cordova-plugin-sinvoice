package com.thomas.sinvoice;

import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import com.libra.sinvoice.Common;
import com.libra.sinvoice.SinVoicePlayer;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;

public class SinVoice extends CordovaPlugin implements SinVoicePlayer.Listener {
    private static final String GET_WIFI_NAME = "getWifiName";
    private static final String START_SEND = "startSend";
    private static final String STOP_SEND = "stopSend";

    private SinVoicePlayer mSinVoicePlayer;
    private final static int[] TOKENS = { 32, 32, 32, 32, 32, 32 };
    private final static String TOKENS_str = "Beeba20141";
    private final static int TOKEN_LEN = TOKENS.length;
    private  WifiManager wifiManager;


    @Override
    protected void pluginInitialize() {
        super.pluginInitialize();
        mSinVoicePlayer = new SinVoicePlayer();
        mSinVoicePlayer.init(cordova.getActivity());
        mSinVoicePlayer.setListener(this);
        wifiManager = (WifiManager) cordova.getActivity().getApplicationContext().getSystemService(cordova.getActivity().getApplicationContext().WIFI_SERVICE);
        System.out.println("pluginInitialize");
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (GET_WIFI_NAME.equals(action)){
            getWifiName(callbackContext);
        }else if (START_SEND.equals(action)){//开始发送
            String wifi = args.getString(0);
            String password = args.getString(1);
            startSend(wifi,password);
            return true;
        }else if (STOP_SEND.equals(action)){//停止发送
            stopSend();
            return true;
        }

        return false;
    }

    private void getWifiName(CallbackContext callbackContext) {

        WifiInfo mWifiInfo = wifiManager.getConnectionInfo();
        String ssid = null;
        if (mWifiInfo != null ) {
            int len = mWifiInfo.getSSID().length();
            if (mWifiInfo.getSSID().startsWith("\"") && mWifiInfo.getSSID().endsWith("\"")) {
                ssid = mWifiInfo.getSSID().substring(1, len - 1);
            } else {
                ssid = mWifiInfo.getSSID();
            }
        }
//        JSONObject jsonObject = new JSONObject();
//        try {
//            jsonObject.put("ssid",ssid);
//            jsonObject.put("bssid",mWifiInfo.getBSSID());
//        } catch (JSONException e) {
//            e.printStackTrace();
//        }
        callbackContext.success(ssid);
    }




    private void startSend(String wifi,String password) {
        System.loadLibrary("sinvoice");
        try {
            String sendStr = wifi+"||"+password;
            byte[] strs = sendStr.getBytes("UTF8");
            if ( null != strs ) {
                int len = strs.length;
                int []tokens = new int[len];
                int maxEncoderIndex = mSinVoicePlayer.getMaxEncoderIndex();
                String encoderText = sendStr;
                for ( int i = 0; i < len; ++i ) {
                    if ( maxEncoderIndex < 255 ) {
                        tokens[i] = Common.DEFAULT_CODE_BOOK.indexOf(encoderText.charAt(i));
                    } else {
                        tokens[i] = strs[i];
                    }
                }
                mSinVoicePlayer.play(tokens, len, false, 2000);
            } else {
                mSinVoicePlayer.play(TOKENS, TOKEN_LEN, false, 2000);
            }
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
    }

    private void stopSend() {
        mSinVoicePlayer.stop();
    }


    @Override
    public void onSinVoicePlayStart() {

    }

    @Override
    public void onSinVoicePlayEnd() {

    }

    @Override
    public void onSinToken(int[] tokens) {

    }
}
