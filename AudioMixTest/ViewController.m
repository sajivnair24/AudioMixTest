//
//  ViewController.m
//  AudioMixTest
//
//  Created by Sajiv Nair on 14/04/15.
//  Copyright (c) 2015 Sajiv Nair. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *tracks = [NSArray arrayWithObjects: @"/Users/Sajiv/Downloads/Batameez.m4a", @"/Users/Sajiv/Downloads/Tujhi.m4a", @"/Users/Sajiv/Downloads/Chand.m4a", nil];
    
    NSString *mixedFile = [self mixAudioFiles:tracks];
    NSLog(mixedFile, "");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*)mixAudioFiles:(NSArray*)audioFileURLArray {
    
    NSError* error = nil;
    AVURLAsset* fileAsset;
    NSString *outputFile;
    AVAssetExportSession* exportSession;
    AVMutableCompositionTrack* audioTrack;
    AVMutableComposition* composition = [AVMutableComposition composition];
    
    int size = [audioFileURLArray count];
    
    for(int i = 0; i < size; i++) {
        
        audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                  preferredTrackID:kCMPersistentTrackID_Invalid];
        
        fileAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:[audioFileURLArray objectAtIndex:i]]      options:nil];
        
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, fileAsset.duration)
                             ofTrack:[[fileAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                             atTime:kCMTimeZero
                             error:&error];
    }
    
    exportSession = [AVAssetExportSession
                     exportSessionWithAsset:composition
                     presetName:AVAssetExportPresetAppleM4A];
    
    outputFile = @"/Users/Sajiv/Downloads/Combined.m4a";
    
    exportSession.outputURL = [NSURL fileURLWithPath:outputFile]; // output path
    exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        // export status changed, check to see if it's done, errored, waiting, etc
        switch (exportSession.status)
        {
            case AVAssetExportSessionStatusFailed:
                break;
            case AVAssetExportSessionStatusCompleted:
                break;
            case AVAssetExportSessionStatusWaiting:
                break;
            default:
                break;
        }
    }];
    
    return outputFile;
}

@end
