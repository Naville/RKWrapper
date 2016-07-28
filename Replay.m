//
//  Replay.m
//  Replay
//
//  Created by Zhang Naville on 16/3/19.
//  Copyright © 2016年 NavilleZhang. All rights reserved.
//
#import "Replay.h"
@implementation Replay
+(id)sharedInstance{
    static Replay* MR=nil;
    static dispatch_once_t Meh;
    dispatch_once(&Meh, ^{
        MR = [[self alloc] init];
    });
    return MR;
    
}
-(instancetype)init{
    self=[super init];
    void* Handle=dlopen("/System/Library/Frameworks/ReplayKit.framework/ReplayKit", RTLD_NOW);
    if (Handle==NULL){
        NSNotificationCenter* NSC=[NSNotificationCenter defaultCenter];
        [NSC postNotificationName:InitErrorName object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:dlerror()],@"Error",nil]];
        return nil;
    }
    Class RK=objc_getClass("RPScreenRecorder");
    if (RK==nil){
        NSNotificationCenter* NSC=[NSNotificationCenter defaultCenter];
        [NSC postNotificationName:InitErrorName object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Class Not Found",@"Error",nil]];
        return nil;
    }
    self->Recorder=[RK sharedRecorder];
    if(self->Recorder.available==NO){
        NSNotificationCenter* NSC=[NSNotificationCenter defaultCenter];
        [NSC postNotificationName:InitErrorName object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"ReplayKit Not Supported",@"Error",nil]];
        return nil;
    }
    return self;
}
-(int)StartRecording{
    if(self->isBusy==YES){
        return RKBusy;
    }
    __block int Status=RKOK;
    [self->Recorder startRecordingWithMicrophoneEnabled:NO handler:^(NSError * _Nullable error) {
        if(error!=nil){
            NSLog(@"RKError:%@",error.localizedDescription);
            NSNotificationCenter* NSC=[NSNotificationCenter defaultCenter];
            [NSC postNotificationName:StartErrorName object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error.localizedDescription,@"Error",nil]];
            Status=RKError;
        }
        else{
            self->isBusy=YES;
            Status=RKOK;
        }
    }];
    return Status;
}
-(int)StopRecordingWithVC:(UIViewController*)rootVC{
    if (self->isBusy==NO) {
        return RKUninit;
    }
    if (rootVC==nil) {
        return RKNILvc;
    }
    __block int Status=RKOK;
    [self->Recorder stopRecordingWithHandler:^(RPPreviewViewController* previewViewController, NSError * _Nullable error) {
        if(error!=nil){
            NSLog(@"RKError:%@",error.localizedDescription);
            NSNotificationCenter* NSC=[NSNotificationCenter defaultCenter];
            [NSC postNotificationName:StopErrorName object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:error.localizedDescription,@"Error",nil]];
            Status=RKError;
        }
        else{
            previewViewController.previewControllerDelegate =(id<RPPreviewViewControllerDelegate>)self;

            previewViewController.modalPresentationStyle=UIModalPresentationFullScreen;
            NSLog(@"ReplayKit-----Presenting VC:%@ With rootVC:%@",previewViewController,rootVC);
            [rootVC presentViewController:previewViewController animated:NO completion:nil];
            self->isBusy=NO;
        }

    }];
    
    
    return Status;
}
- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController {
    [previewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet <NSString *> *)activityTypes {
    NSNotificationCenter* NSC=[NSNotificationCenter defaultCenter];
    [NSC postNotificationName:VCStatusName object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:activityTypes.allObjects,@"activityTypes",nil]];
}
@end
