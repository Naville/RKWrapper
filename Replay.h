//
//  Replay.h
//  Replay
//
//  Created by Zhang Naville on 16/3/19.
//  Copyright © 2016年 NavilleZhang. All rights reserved.
//
#import <dlfcn.h>
#import <Foundation/Foundation.h>
#import <ReplayKit/ReplayKit.h>
#import <objc/runtime.h>
#define RKError 2588
#define RKBusy 1830
#define RKOK 0
#define RKNILvc 2588
#define RKUninit 1208

#define StartErrorName @"com.malody.replaykit.starterror"
#define StopErrorName @"com.malody.replaykit.stoperror"
#define VCStatusName @"com.malody.replaykit.activitytypes"
#define InitErrorName @"com.malody.replaykit.dlerror"


@interface Replay : NSObject{
    RPScreenRecorder* Recorder;
    BOOL isBusy;
    
}
+(id)sharedInstance;
-(int)StartRecording;
-(int)StopRecordingWithVC:(UIViewController*)rootVC;
@end
