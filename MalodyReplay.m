//
//  MalodyReplay.m
//  MalodyReplay
//
//  Created by Zhang Naville on 16/3/19.
//  Copyright © 2016年 NavilleZhang. All rights reserved.
//
#import "MalodyReplay.h"
@implementation MalodyReplay
+(id)sharedInstance{
    static MalodyReplay* MR=nil;
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
        return nil;
    }
    Class RK=objc_getClass("RPScreenRecorder");
    if (RK==nil){
        return nil;
    }
    self->Recorder=[RK sharedRecorder];
    return self;
}
-(int)StartRecording{
    if(self->isBusy==YES){
        return RKBusy;
    }
    __block int Status=RKOK;
    [self->Recorder startRecordingWithMicrophoneEnabled:YES handler:^(NSError * _Nullable error) {
        if(error!=nil){
#ifdef DEBUG
            NSLog(@"RKError:%@",error.localizedDescription);
#endif
            Status=RKError;
        }
        else{
            self->isBusy=YES;
            Status=RKOK;
        }
    }];
    return Status;
}
-(int)StopRecording{
    if (self->isBusy==NO) {
        return RKUninit;
    }
    __block int Status=RKOK;
    [self->Recorder stopRecordingWithHandler:^(RPPreviewViewController* previewViewController, NSError * _Nullable error) {
        if(error!=nil){
#ifdef DEBUG
            NSLog(@"RKError:%@",error.localizedDescription);
#endif
            Status=RKError;
        }
        else{
        UIViewController* rootVC=(UIViewController*)[[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];
            previewViewController.previewControllerDelegate =(id<RPPreviewViewControllerDelegate>)self;
            [rootVC presentViewController:previewViewController animated:YES completion:^(){
                
            }];
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
    [NSC postNotificationName:@"com.malody.replaykit" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:activityTypes.allObjects,@"activityTypes",nil]];
}
@end
