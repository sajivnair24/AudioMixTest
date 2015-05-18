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
    
    NSString *masterFile;
    NSString *activeFile;
    AVURLAsset* masterAsset;
    AVURLAsset* activeAsset;
    
    NSError* error = nil;
    AVAssetExportSession* exportSession;
    
    AVMutableComposition* composition = [AVMutableComposition composition];
    AVMutableCompositionTrack* audioTrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                     preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack* audioTrack2 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                      preferredTrackID:kCMPersistentTrackID_Invalid];
    int size = [audioFileURLArray count];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for(int i = 1; i < size; i++) {
        
        if(i == 1) {
            masterFile = [audioFileURLArray objectAtIndex:(i - 1)];
        }
        
        activeFile = [audioFileURLArray objectAtIndex:i];
        
        // grab the two audio assets as AVURLAssets according to the file paths
        masterAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:masterFile] options:nil];
        activeAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:activeFile] options:nil];
        
        [audioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, masterAsset.duration)
                     ofTrack:[[masterAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                     atTime:kCMTimeZero
                     error:&error];
        
        // mix the entirety of the active recording
        [audioTrack2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, activeAsset.duration)
                     ofTrack:[[activeAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                     atTime:kCMTimeZero
                     error:&error];
        
        // now export the two files
        // create the export session
        // no need for a retain here, the session will be retained by the
        // completion handler since it is referenced there
        
        exportSession = [AVAssetExportSession
                         exportSessionWithAsset:composition
                         presetName:AVAssetExportPresetAppleM4A];
        
        if((i > 1) && [fileManager fileExistsAtPath:masterFile]) {
            [fileManager removeItemAtPath:masterFile error:&error];
        }

        // create a new file for the combined file
        masterFile = @"/Users/Sajiv/Downloads/Combined.m4a";
        
        // configure export session  output with all our parameters
        exportSession.outputURL = [NSURL fileURLWithPath:masterFile]; // output path
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
        
        // Give some time for mixed file creation.
        sleep(5);
    }
    
    return masterFile;
}

@end
