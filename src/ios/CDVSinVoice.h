//
//  GSViewController.h
//  iosTest
//
//  Created by gujicheng on 14-6-28.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinVoicePlayer.h"
#import "SinVoiceRecognizer.h"
#include "ESPcmPlayer.h"
#include "ESPcmRecorder.h"
#import <Cordova/CDVPlugin.h>

@interface CDVSinVoice : CDVPlugin
{
    @private
    SinVoicePlayer*     mSinVoicePlayer;
    SinVoiceRecognizer* mSinVoiceRecorder;
    ESPcmPlayer         mPcmPlayer;
    ESPcmRecorder       mPcmRecorder;

    @public
    int mRates[100];
    int mPlayCount;
    int mResults[100];
    int mResultCount;
    int mMaxEncoderIndex;
}

- (void)getWifiName:(CDVInvokedUrlCommand*)command;
- (void)startSend:(CDVInvokedUrlCommand*)command;
- (void)stopSend:(CDVInvokedUrlCommand*)command;
@end
