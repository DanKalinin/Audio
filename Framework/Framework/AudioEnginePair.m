//
//  AudioStreamPair.m
//  Intercom
//
//  Created by Dan Kalinin on 7/27/17.
//  Copyright © 2017 Dan Kalinin. All rights reserved.
//

#import "AudioEnginePair.h"










@interface AudioEngine ()

@property SurrogateArray<AudioEngineDelegate> *delegates;
@property AVAudioConverter *converter;
@property NSError *error;

@end



@implementation AudioEngine

- (instancetype)init {
    self = super.init;
    if (self) {
        self.delegates = (id)SurrogateArray.new;
        [self.delegates addObject:self];
    }
    return self;
}

- (AVAudioConverterOutputStatus)convertToBuffer:(AVAudioBuffer *)outputBuffer fromBuffer:(AVAudioBuffer *)inputBuffer error:(NSError **)error {
    __block BOOL converted = NO;
    AVAudioConverterOutputStatus status = [self.converter convertToBuffer:outputBuffer error:error withInputFromBlock:^AVAudioBuffer *(AVAudioPacketCount inNumberOfPackets, AVAudioConverterInputStatus *outStatus) {
        AVAudioBuffer *buffer = nil;
        if (self.running) {
            if (converted) {
                *outStatus = AVAudioConverterInputStatus_NoDataNow;
            } else {
                *outStatus = AVAudioConverterInputStatus_HaveData;
                buffer = inputBuffer;
            }
        } else {
            *outStatus = AVAudioConverterInputStatus_EndOfStream;
        }
        converted = YES;
        return buffer;
    }];
    return status;
}

@end










@interface InputAudioEngine ()

@end



@implementation InputAudioEngine

@dynamic delegates;

- (instancetype)initWithOutputFormat:(AVAudioFormat *)outputFormat {
    self = super.init;
    if (self) {
        AVAudioFormat *inputFormat = [self.inputNode inputFormatForBus:1];
        self.converter = [AVAudioConverter.alloc initFromFormat:inputFormat toFormat:outputFormat];
        
        [self.inputNode installTapOnBus:0 bufferSize:4096 format:inputFormat block:^(AVAudioPCMBuffer *buffer, AVAudioTime *when) {
            AVAudioPCMBuffer *inputBuffer = buffer;
            AVAudioCompressedBuffer *outputBuffer = [AVAudioCompressedBuffer.alloc initWithFormat:outputFormat packetCapacity:8 maximumPacketSize:self.converter.maximumOutputPacketSize];
            NSError *error = nil;
            AVAudioConverterOutputStatus status = [self convertToBuffer:outputBuffer fromBuffer:inputBuffer error:&error];
            if ((status == AVAudioConverterOutputStatus_HaveData) || (status == AVAudioConverterOutputStatus_InputRanDry)) {
                [self.delegates inputAudioEngine:self didCompressBuffer:outputBuffer atTime:when];
            } else if (status == AVAudioConverterOutputStatus_Error) {
                [self stop];
                self.error = error;
                [self.delegates audioEngineErrorOccurred:self];
            }
        }];
    }
    return self;
}

@end










@interface OutputAudioEngine ()

@property AVAudioPlayerNode *playerNode;

@end



@implementation OutputAudioEngine

@dynamic delegates;

- (instancetype)initWithInputFormat:(AVAudioFormat *)inputFormat {
    self = super.init;
    if (self) {
        AVAudioFormat *outputFormat = [self.outputNode outputFormatForBus:0];
        self.converter = [AVAudioConverter.alloc initFromFormat:inputFormat toFormat:outputFormat];
        
        self.playerNode = AVAudioPlayerNode.new;
        [self attachNode:self.playerNode];
        [self connect:self.playerNode to:self.outputNode format:outputFormat];
    }
    return self;
}

- (BOOL)startAndReturnError:(NSError **)outError {
    BOOL success = [super startAndReturnError:outError];
    if (success) {
        [self.playerNode play];
    }
    return success;
}

- (void)pause {
    [super pause];
    
    [self.playerNode pause];
}

- (void)stop {
    [super stop];
    
    [self.playerNode stop];
}

- (void)scheduleBuffer:(AVAudioCompressedBuffer *)buffer atTime:(AVAudioTime *)when options:(AVAudioPlayerNodeBufferOptions)options completionHandler:(AVAudioNodeCompletionHandler)completionHandler {
    AVAudioCompressedBuffer *inputBuffer = buffer;
    AVAudioPCMBuffer *outputBuffer = [AVAudioPCMBuffer.alloc initWithPCMFormat:self.converter.outputFormat frameCapacity:4410];
    NSError *error = nil;
    AVAudioConverterOutputStatus status = [self convertToBuffer:outputBuffer fromBuffer:inputBuffer error:&error];
    if ((status == AVAudioConverterOutputStatus_HaveData) || (status == AVAudioConverterOutputStatus_InputRanDry)) {
        [self.playerNode scheduleBuffer:outputBuffer atTime:when options:options completionHandler:completionHandler];
    } else if (status == AVAudioConverterOutputStatus_Error) {
        [self stop];
        self.error = error;
        [self.delegates audioEngineErrorOccurred:self];
    }
}

- (void)scheduleBuffer:(AVAudioCompressedBuffer *)buffer completionHandler:(AVAudioNodeCompletionHandler)completionHandler {
    [self scheduleBuffer:buffer atTime:nil options:0 completionHandler:completionHandler];
}

@end










@interface AudioEnginePair ()

@property AVAudioFormat *format;
@property InputAudioEngine *inputEngine;
@property OutputAudioEngine *outputEngine;

@end



@implementation AudioEnginePair

- (instancetype)initWithFormat:(AVAudioFormat *)format {
    self = super.init;
    if (self) {
        self.format = format;
        self.inputEngine = [InputAudioEngine.alloc initWithOutputFormat:format];
        self.outputEngine = [OutputAudioEngine.alloc initWithInputFormat:format];
    }
    return self;
}

- (BOOL)startAndReturnError:(NSError **)outError {
    BOOL success = ([self.inputEngine startAndReturnError:outError] && [self.outputEngine startAndReturnError:outError]);
    return success;
}

- (void)pause {
    [self.inputEngine pause];
    [self.outputEngine pause];
}

- (void)stop {
    [self.inputEngine stop];
    [self.outputEngine stop];
}

@end
