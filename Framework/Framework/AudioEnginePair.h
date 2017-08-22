//
//  AudioStreamPair.h
//  Intercom
//
//  Created by Dan Kalinin on 7/27/17.
//  Copyright © 2017 Dan Kalinin. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Helpers/Helpers.h>

@class AudioEngine, InputAudioEngine, OutputAudioEngine;










@protocol AudioEngineDelegate <NSObject>

@optional
- (void)audioEngineErrorOccurred:(AudioEngine *)engine;

@end



@interface AudioEngine : AVAudioEngine <AudioEngineDelegate>

@property (readonly) SurrogateArray<AudioEngineDelegate> *delegates;
@property (readonly) AVAudioConverter *converter;
@property (readonly) NSError *error;

- (AVAudioConverterOutputStatus)convertToBuffer:(AVAudioBuffer *)outputBuffer fromBuffer:(AVAudioBuffer *)inputBuffer error:(NSError **)error;

@end










@protocol InputAudioEngineDelegate <AudioEngineDelegate>

@optional
- (void)inputAudioEngine:(InputAudioEngine *)engine didCompressBuffer:(AVAudioCompressedBuffer *)buffer atTime:(AVAudioTime *)time;

@end



@interface InputAudioEngine : AudioEngine <InputAudioEngineDelegate>

@property (readonly) SurrogateArray<InputAudioEngineDelegate> *delegates;

@end










@protocol OutputAudioEngineDelegate <AudioEngineDelegate>

@optional

@end



@interface OutputAudioEngine : AudioEngine <OutputAudioEngineDelegate>

@property (readonly) SurrogateArray<OutputAudioEngineDelegate> *delegates;
@property (readonly) AVAudioPlayerNode *playerNode;

- (void)scheduleBuffer:(AVAudioCompressedBuffer *)buffer atTime:(AVAudioTime *)when options:(AVAudioPlayerNodeBufferOptions)options completionHandler:(AVAudioNodeCompletionHandler)completionHandler;
- (void)scheduleBuffer:(AVAudioCompressedBuffer *)buffer completionHandler:(AVAudioNodeCompletionHandler)completionHandler;

@end










@interface AudioEnginePair : AVAudioEngine;

@property (readonly) AVAudioFormat *format;
@property (readonly) InputAudioEngine *inputEngine;
@property (readonly) OutputAudioEngine *outputEngine;

- (instancetype)initWithFormat:(AVAudioFormat *)format;

@end
