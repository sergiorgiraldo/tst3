//
//  FartAudioEngine.m
//  FartScrollLid
//
//  Created by Sam on 2025-09-06.
//

#import "FartAudioEngine.h"

// Pitch mapping constants (lid angle to pitch)
static const double kMinPitch = 0.5;           // Lowest pitch (deep fart) when lid closed
static const double kMaxPitch = 2.0;           // Highest pitch (squeaky fart) when lid open
static const double kAngleForMinPitch = 5.0;   // Angle for deepest fart
static const double kAngleForMaxPitch = 130.0; // Angle for highest fart

// Volume mapping constants (velocity to volume)
static const double kMinVolume = 0.0;          // Minimum volume (silence when not moving)
static const double kMaxVolume = 1.0;          // Maximum volume
static const double kVelocityForMaxVolume = 50.0; // deg/s for loudest fart
static const double kMovementThreshold = 2.0;  // deg/s - minimum velocity to trigger fart
static const double kVolumeDecayRate = 0.92;   // How quickly volume decays when stopped

// Smoothing constants
static const double kAngleSmoothingFactor = 0.1;      // Smooth angle changes
static const double kVelocitySmoothingFactor = 0.3;   // Smooth velocity changes
static const double kPitchRampTimeMs = 30.0;          // Pitch ramping time
static const double kVolumeRampTimeMs = 50.0;         // Volume ramping time

@interface FartAudioEngine ()

// Audio engine components
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) AVAudioPlayerNode *fartPlayerNode;
@property (nonatomic, strong) AVAudioUnitVarispeed *varispeedUnit;
@property (nonatomic, strong) AVAudioMixerNode *mixerNode;

// Audio file
@property (nonatomic, strong) AVAudioFile *fartLoopFile;
@property (nonatomic, strong) AVAudioPCMBuffer *fartBuffer;

// State tracking
@property (nonatomic, assign) double lastLidAngle;
@property (nonatomic, assign) double smoothedLidAngle;
@property (nonatomic, assign) double lastUpdateTime;
@property (nonatomic, assign) double smoothedVelocity;
@property (nonatomic, assign) double targetPitch;
@property (nonatomic, assign) double targetVolume;
@property (nonatomic, assign) double currentPitch;
@property (nonatomic, assign) double currentVolume;
@property (nonatomic, assign) BOOL isFirstUpdate;

@end

@implementation FartAudioEngine

- (instancetype)init {
    self = [super init];
    if (self) {
        _isFirstUpdate = YES;
        _lastUpdateTime = CACurrentMediaTime();
        _lastLidAngle = 0.0;
        _smoothedLidAngle = 0.0;
        _smoothedVelocity = 0.0;
        _targetPitch = 1.0;
        _targetVolume = 0.5;
        _currentPitch = 1.0;
        _currentVolume = 0.5;
        
        if (![self setupAudioEngine]) {
            NSLog(@"[FartAudioEngine] Failed to setup audio engine");
            return nil;
        }
        
        if (![self loadAudioFiles]) {
            NSLog(@"[FartAudioEngine] Failed to load audio files");
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    [self stopEngine];
}

#pragma mark - Audio Engine Setup

- (BOOL)setupAudioEngine {
    self.audioEngine = [[AVAudioEngine alloc] init];
    
    // Create audio nodes
    self.fartPlayerNode = [[AVAudioPlayerNode alloc] init];
    self.varispeedUnit = [[AVAudioUnitVarispeed alloc] init];
    self.mixerNode = self.audioEngine.mainMixerNode;
    
    // Attach nodes to engine
    [self.audioEngine attachNode:self.fartPlayerNode];
    [self.audioEngine attachNode:self.varispeedUnit];
    
    // Connect nodes: Player -> Varispeed -> Mixer
    AVAudioFormat *format = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100.0 channels:2];
    
    [self.audioEngine connect:self.fartPlayerNode
                           to:self.varispeedUnit
                       format:format];
    
    [self.audioEngine connect:self.varispeedUnit
                           to:self.mixerNode
                       format:format];
    
    NSLog(@"[FartAudioEngine] Audio engine setup complete");
    return YES;
}

- (BOOL)loadAudioFiles {
    NSBundle *bundle = [NSBundle mainBundle];
    
    // First try to load FART.wav, if not available, use CREAK_LOOP.wav temporarily
    NSURL *fartURL = [bundle URLForResource:@"FART" withExtension:@"wav"];
    
    if (!fartURL) {
        // Fall back to existing CREAK_LOOP.wav for now
        fartURL = [bundle URLForResource:@"CREAK_LOOP" withExtension:@"wav"];
        if (!fartURL) {
            NSLog(@"[FartAudioEngine] No audio file found");
            return NO;
        }
        NSLog(@"[FartAudioEngine] Using CREAK_LOOP.wav as placeholder - please add FART.wav");
    }
    
    NSError *error = nil;
    self.fartLoopFile = [[AVAudioFile alloc] initForReading:fartURL error:&error];
    
    if (error) {
        NSLog(@"[FartAudioEngine] Error loading fart loop: %@", error.localizedDescription);
        return NO;
    }
    
    // Load the audio file into a buffer for looping playback
    AVAudioFormat *format = self.fartLoopFile.processingFormat;
    AVAudioFrameCount frameCount = (AVAudioFrameCount)self.fartLoopFile.length;
    
    self.fartBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format frameCapacity:frameCount];
    
    [self.fartLoopFile readIntoBuffer:self.fartBuffer error:&error];
    
    if (error) {
        NSLog(@"[FartAudioEngine] Error reading fart file into buffer: %@", error.localizedDescription);
        return NO;
    }
    
    NSLog(@"[FartAudioEngine] Audio files loaded successfully");
    return YES;
}

#pragma mark - Engine Control

- (void)startEngine {
    if (self.isEngineRunning) {
        return;
    }
    
    NSError *error = nil;
    [self.audioEngine startAndReturnError:&error];
    
    if (error) {
        NSLog(@"[FartAudioEngine] Error starting audio engine: %@", error.localizedDescription);
        return;
    }
    
    // Start looped playback
    [self.fartPlayerNode scheduleBuffer:self.fartBuffer
                                atTime:nil
                               options:AVAudioPlayerNodeBufferLoops
                     completionHandler:nil];
    
    [self.fartPlayerNode play];
    
    // Set initial parameters
    self.varispeedUnit.rate = self.currentPitch;
    self.mixerNode.outputVolume = self.currentVolume;
    
    _isEngineRunning = YES;
    NSLog(@"[FartAudioEngine] Engine started - Let the farts begin!");
}

- (void)stopEngine {
    if (!self.isEngineRunning) {
        return;
    }
    
    [self.fartPlayerNode stop];
    [self.audioEngine stop];
    
    _isEngineRunning = NO;
    NSLog(@"[FartAudioEngine] Engine stopped - Farts silenced");
}

#pragma mark - Lid Angle Updates

- (void)updateWithLidAngle:(double)lidAngle {
    double currentTime = CACurrentMediaTime();
    double deltaTime = currentTime - self.lastUpdateTime;
    
    // Skip if time delta is too small
    if (deltaTime < 0.001) {
        return;
    }
    
    // Apply smoothing to lid angle
    if (self.isFirstUpdate) {
        self.smoothedLidAngle = lidAngle;
        self.lastLidAngle = lidAngle;
        self.isFirstUpdate = NO;
    } else {
        self.smoothedLidAngle = (kAngleSmoothingFactor * lidAngle) + 
                                ((1.0 - kAngleSmoothingFactor) * self.smoothedLidAngle);
    }
    
    // Calculate angular velocity
    double instantVelocity = fabs(self.smoothedLidAngle - self.lastLidAngle) / deltaTime;
    
    // Smooth the velocity
    self.smoothedVelocity = (kVelocitySmoothingFactor * instantVelocity) + 
                            ((1.0 - kVelocitySmoothingFactor) * self.smoothedVelocity);
    
    // Calculate target pitch based on lid angle (closed = low, open = high)
    double normalizedAngle = (self.smoothedLidAngle - kAngleForMinPitch) / 
                            (kAngleForMaxPitch - kAngleForMinPitch);
    normalizedAngle = fmax(0.0, fmin(1.0, normalizedAngle)); // Clamp to 0-1
    
    self.targetPitch = kMinPitch + (normalizedAngle * (kMaxPitch - kMinPitch));
    
    // Calculate target volume based on velocity (only fart when moving)
    if (self.smoothedVelocity > kMovementThreshold) {
        // Moving - play fart sound with volume based on speed
        double normalizedVelocity = self.smoothedVelocity / kVelocityForMaxVolume;
        normalizedVelocity = fmax(0.0, fmin(1.0, normalizedVelocity)); // Clamp to 0-1
        self.targetVolume = kMinVolume + (normalizedVelocity * (kMaxVolume - kMinVolume));
    } else {
        // Not moving - quickly fade to silence
        self.targetVolume = self.currentVolume * kVolumeDecayRate;
        if (self.targetVolume < 0.01) {
            self.targetVolume = 0.0;
        }
    }
    
    // Apply ramping to avoid audio artifacts
    double pitchRampFactor = 1.0 - exp(-deltaTime * 1000.0 / kPitchRampTimeMs);
    double volumeRampFactor = 1.0 - exp(-deltaTime * 1000.0 / kVolumeRampTimeMs);
    
    self.currentPitch += (self.targetPitch - self.currentPitch) * pitchRampFactor;
    self.currentVolume += (self.targetVolume - self.currentVolume) * volumeRampFactor;
    
    // Apply audio parameters if engine is running
    if (self.isEngineRunning) {
        self.varispeedUnit.rate = self.currentPitch;
        self.mixerNode.outputVolume = self.currentVolume;
    }
    
    // Update state for next iteration
    self.lastLidAngle = self.smoothedLidAngle;
    self.lastUpdateTime = currentTime;
    _currentVelocity = self.smoothedVelocity;
}

@end
