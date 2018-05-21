//
//  AudioManager.h
//  Intercom
//
//  Created by Dan Kalinin on 7/30/17.
//  Copyright © 2017 Dan Kalinin. All rights reserved.
//

#import <PushKit/PushKit.h>
#import <CallKit/CallKit.h>
#import "AudioEnginePair.h"

@class AudioManager, NavigationAudioManager, PodcastAudioManager;










@protocol AudioManagerDelegate <NSObject>

@optional
- (void)audioManagerErrorOccurred:(AudioManager *)manager;

@end



@interface AudioManager : NSObject <AudioManagerDelegate>

@property (readonly) SurrogateArray<AudioManagerDelegate> *delegates;
@property (readonly) AVAudioSession *audioSession;
@property BOOL hasPlaybackUI;

- (void)audioSessionInterruptionNotification:(NSNotification *)note;
- (void)audioSessionRouteChangeNotification:(NSNotification *)note;
- (void)audioSessionSilenceSecondaryAudioHintNotification:(NSNotification *)note;
- (void)audioSessionMediaServicesWereLostNotification:(NSNotification *)note;
- (void)audioSessionMediaServicesWereResetNotification:(NSNotification *)note;

- (void)audioManagerErrorOccurred:(AudioManager *)manager;

@end










@interface NavigationAudioManager : AudioManager

- (instancetype)initWithError:(NSError **)error;

@end










@interface PodcastAudioManager : AudioManager

- (instancetype)initWithError:(NSError **)error;

@end










@interface ProductivityAudioManager : AudioManager

- (instancetype)initWithError:(NSError **)error;

@end










@interface VoIPAudioManager : AudioManager <InputAudioEngineDelegate, OutputAudioEngineDelegate, NSInputStreamDelegate, NSOutputStreamDelegate, CXProviderDelegate, CXCallObserverDelegate, PKPushRegistryDelegate>

@property PKPushRegistry *pushRegistry; // Set during initialization
@property CXProvider *provider;
@property CXCallController *callController;
@property AudioEnginePair *audioEnginePair;
@property HLPStreamPair *streamPair;

- (instancetype)initWithError:(NSError **)error;

@end
