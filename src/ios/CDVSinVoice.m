//
//  GSViewController.m
//  iosTest
//
//  Created by gujicheng on 14-6-28.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "CDVSinVoice.h"
#import "MyPcmPlayerImp.h"
#import "MyPcmRecorderImp.h"
#import <SystemConfiguration/CaptiveNetwork.h>

//static const char* const CODE_BOOK = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@_";
static const char* const CODE_BOOK ="0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@_~!#$%^&*,:;./\\[]{}<>|`+-=\"";

#define TOKEN_COUNT 24

#import <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioSession.h>

FILE*   mFile;


ESVoid onSinVoicePlayerStart(ESVoid* cbParam) {
    NSLog(@"onSinVoicePlayerStart, start");
    CDVSinVoice* vc = (__bridge CDVSinVoice*)cbParam;
//    [vc onPlayData:vc];
    NSLog(@"onPlayData, end");
}

ESVoid onSinVoicePlayerStop(ESVoid* cbParam) {
    NSLog(@"onSinVoicePlayerStop");
}

SinVoicePlayerCallback gSinVoicePlayerCallback = {onSinVoicePlayerStart, onSinVoicePlayerStop};

@interface CDVSinVoice ()

@end

@implementation CDVSinVoice

-(void)pluginInitialize{
    //    mSinVoicePlayer = SinVoicePlayer_create("com.sinvoice.demo", "SinVoiceDemo", &gSinVoicePlayerCallback, (__bridge ESVoid *)(self));
    mPcmPlayer.create = MyPcmPlayerImp_create;
    mPcmPlayer.start = MyPcmPlayerImp_start;
    mPcmPlayer.stop = MyPcmPlayerImp_stop;
    mPcmPlayer.setParam = MyPcmPlayerImp_setParam;
    mPcmPlayer.destroy = MyPcmPlayerImp_destroy;
    mSinVoicePlayer = SinVoicePlayer_create2("com.sinvoice.demo", "SinVoiceDemo", &gSinVoicePlayerCallback, (__bridge ESVoid *)(self), &mPcmPlayer);
    
    //    mSinVoiceRecorder = SinVoiceRecognizer_create("com.sinvoice.demo", "SinVoiceDemo", &gSinVoiceRecognizerCallback, (__bridge ESVoid *)(self));
    mPcmRecorder.create = MyPcmRecorderImp_create;
    mPcmRecorder.start = MyPcmRecorderImp_start;
    mPcmRecorder.stop = MyPcmRecorderImp_stop;
    mPcmRecorder.setParam = MyPcmRecorderImp_setParam;
    mPcmRecorder.destroy = MyPcmRecorderImp_destroy;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    
    mMaxEncoderIndex = SinVoicePlayer_getMaxEncoderIndex(mSinVoicePlayer);
}

- (void)getWifiName:(CDVInvokedUrlCommand*)command{
    
    CDVPluginResult* pluginResult = nil;
    NSString *apSsid = [self currentWifiSSID];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:apSsid];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (NSString *)currentWifiSSID
{
    NSString *ssid = nil;
    NSArray *ifs = (__bridge   id)CNCopySupportedInterfaces();
    for (NSString *ifname in ifs) {
        NSDictionary *info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
        if (info[@"SSID"])
        {
            ssid = info[@"SSID"];
        }
    }
    return ssid;
}
- (void)startSend:(CDVInvokedUrlCommand*)command{
    NSArray *arguments = command.arguments;
    NSString *ssid = arguments[0];
    NSString *password = arguments[1];
    NSString *splitStr = @"||";
    NSLog(@"push start play");
    int index = 0;
    NSString* xx = [NSString stringWithFormat:@"%@%@%@",ssid, splitStr,password];
    const char* str = [xx cStringUsingEncoding:NSUTF8StringEncoding];
    
    mPlayCount = (int)strlen(str);
    
    if ( mMaxEncoderIndex < 255 ) {
        int lenCodeBook = (int)strlen(CODE_BOOK);
        int isOK = 1;
        while ( index < mPlayCount) {
            int i = 0;
            for ( i = 0; i < lenCodeBook; ++i ) {
                if ( str[index] == CODE_BOOK[i] ) {
                    mRates[index] = i;
                    break;
                }
            }
            if ( i >= lenCodeBook ) {
                isOK = 0;
                break;
            }
            ++index;
        }
        if ( isOK ) {
            SinVoicePlayer_play(mSinVoicePlayer, mRates, mPlayCount);
        }
    } else {
        int index = 0;
        
        while ( index < mPlayCount) {
            mRates[index] = str[index];
            ++index;
        }
        SinVoicePlayer_play(mSinVoicePlayer, mRates, mPlayCount);
    }
}

- (void)stopSend:(CDVInvokedUrlCommand*)command{
    NSLog(@"push stop play");
    SinVoicePlayer_stop(mSinVoicePlayer);
}


@end
