//
//  AudioManager.m
//  Intercom
//
//  Created by Dan Kalinin on 7/30/17.
//  Copyright © 2017 Dan Kalinin. All rights reserved.
//

#import "AudioManager.h"










@interface AudioManager ()

@property SurrogateArray<AudioManagerDelegate> *delegates;
@property AVAudioSession *audioSession;
@property NSError *error;

@end



@implementation AudioManager

- (instancetype)init {
    self = super.init;
    if (self) {
        self.delegates = (id)SurrogateArray.new;
        
        self.audioSession = AVAudioSession.sharedInstance;
        
        NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
        [nc addObserver:self selector:@selector(audioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:self.audioSession];
        [nc addObserver:self selector:@selector(audioSessionRouteChangeNotification:) name:AVAudioSessionRouteChangeNotification object:self.audioSession];
        [nc addObserver:self selector:@selector(audioSessionSilenceSecondaryAudioHintNotification:) name:AVAudioSessionSilenceSecondaryAudioHintNotification object:self.audioSession];
        [nc addObserver:self selector:@selector(audioSessionMediaServicesWereLostNotification:) name:AVAudioSessionMediaServicesWereLostNotification object:self.audioSession];
        [nc addObserver:self selector:@selector(audioSessionMediaServicesWereResetNotification:) name:AVAudioSessionMediaServicesWereResetNotification object:self.audioSession];
    }
    return self;
}

#pragma mark - Audio session

- (void)audioSessionInterruptionNotification:(NSNotification *)note {
    
}

- (void)audioSessionRouteChangeNotification:(NSNotification *)note {
    
}

- (void)audioSessionSilenceSecondaryAudioHintNotification:(NSNotification *)note {
    
}

- (void)audioSessionMediaServicesWereLostNotification:(NSNotification *)note {
    
}

- (void)audioSessionMediaServicesWereResetNotification:(NSNotification *)note {
    
}

#pragma mark - Audio manager

- (void)audioManagerErrorOccurred:(AudioManager *)manager {
    
}

@end










@interface NavigationAudioManager ()

@end



@implementation NavigationAudioManager

- (instancetype)initWithError:(NSError **)error {
    self = super.init;
    if (self) {
        if (![self.audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:(AVAudioSessionCategoryOptionDuckOthers | AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers) error:error]) return nil;
    }
    return self;
}

@end










@interface PodcastAudioManager ()

@end



@implementation PodcastAudioManager

- (instancetype)initWithError:(NSError **)error {
    self = super.init;
    if (self) {
        if (![self.audioSession setCategory:AVAudioSessionCategoryPlayback error:error]) return nil;
        if (![self.audioSession setMode:AVAudioSessionModeSpokenAudio error:error]) return nil;
    }
    return self;
}

@end










@interface ProductivityAudioManager ()

@end



@implementation ProductivityAudioManager

- (instancetype)initWithError:(NSError **)error {
    self = super.init;
    if (self) {
        if (![self.audioSession setCategory:AVAudioSessionCategoryAmbient error:error]) return nil;
    }
    return self;
}

@end










@interface VoIPAudioManager ()

@end



@implementation VoIPAudioManager

- (instancetype)initWithError:(NSError **)error {
    self = super.init;
    if (self) {
        if (![self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:error]) return nil;
        if (![self.audioSession setMode:AVAudioSessionModeVoiceChat error:error]) return nil;
    }
    return self;
}

#pragma mark - Audio session

- (void)audioSessionInterruptionNotification:(NSNotification *)note {
    [super audioSessionInterruptionNotification:note];
    
    AVAudioSessionInterruptionType type = [note.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    AVAudioSessionInterruptionOptions option = [note.userInfo[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
    BOOL wasSuspended = [note.userInfo[AVAudioSessionInterruptionWasSuspendedKey] boolValue];
    
    (void)wasSuspended;
    
    if (type == AVAudioSessionInterruptionTypeBegan) {
        [self.audioEnginePair stop];
    } else if (type == AVAudioSessionInterruptionTypeEnded) {
        if (!self.hasPlaybackUI || (option & AVAudioSessionInterruptionOptionShouldResume)) {
            NSError *error = nil;
            if (![self.audioSession setActive:YES error:&error] || ![self.audioEnginePair startAndReturnError:&error]) {
                self.error = error;
                [self.delegates audioManagerErrorOccurred:self];
            }
        }
    }
}

- (void)audioSessionRouteChangeNotification:(NSNotification *)note {
    [super audioSessionRouteChangeNotification:note];
    
    AVAudioSessionRouteChangeReason reason = [note.userInfo[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    AVAudioSessionRouteDescription *previousRoute = note.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
    
    (void)reason;
    (void)previousRoute;
    
    // Stop player when headsets unplugged
    // Apply engine properties for new audio device - Sample rate
}

- (void)audioSessionMediaServicesWereResetNotification:(NSNotification *)note {
    [super audioSessionMediaServicesWereResetNotification:note];
    
    self.audioEnginePair = [AudioEnginePair.alloc initWithFormat:self.audioEnginePair.format];
}

#pragma mark - Provider

// Provider events

- (void)providerDidBegin:(CXProvider *)provider {
    
}

- (void)providerDidReset:(CXProvider *)provider {
    
}

// Transaction execution

- (BOOL)provider:(CXProvider *)provider executeTransaction:(CXTransaction *)transaction {
    return NO;
}

// Call actions

- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action {
    
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
    [action fulfillWithDateConnected:NSDate.date];
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
    [action fulfillWithDateEnded:NSDate.date];
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action {
    
}

- (void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action {
    
}

- (void)provider:(CXProvider *)provider performSetGroupCallAction:(CXSetGroupCallAction *)action {
    
}

- (void)provider:(CXProvider *)provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action {
    
}

- (void)provider:(CXProvider *)provider timedOutPerformingAction:(CXAction *)action {
    
}

// Audio session activation

- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {
    
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession {
    
}

#pragma mark - Call controller

- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    NSLog(@"calls - %i", (int)callObserver.calls.count);
}

#pragma mark - Push registry

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type {
    if ([type isEqualToString:PKPushTypeVoIP]) {
        // Remove token from server
    }
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type {
    if ([type isEqualToString:PKPushTypeVoIP]) {
        // CXUpdate, UUID
    }
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(PKPushType)type {
    if ([type isEqualToString:PKPushTypeVoIP]) {
        // Add token to server
    }
}

@end
