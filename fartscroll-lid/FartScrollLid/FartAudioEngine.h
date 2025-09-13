//
//  FartAudioEngine.h
//  FartScrollLid
//
//  Created by Sam on 2025-09-06.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/**
 * FartAudioEngine provides hilarious fart sounds that respond to MacBook lid angle changes.
 * 
 * Features:
 * - Continuous fart sound playback with pitch modulation
 * - Pitch changes based on lid angle (closed = low pitch, open = high pitch)
 * - Volume modulation based on movement speed (faster = louder)
 * - Smooth parameter transitions to avoid audio artifacts
 * 
 * Audio Behavior:
 * - Lid closed (0-10°): Deep, low-pitched fart
 * - Lid partially open (10-90°): Mid-range fart pitch
 * - Lid fully open (90-130°): High-pitched squeaky fart
 * - Movement speed affects volume intensity
 */
@interface FartAudioEngine : NSObject

@property (nonatomic, assign, readonly) BOOL isEngineRunning;
@property (nonatomic, assign, readonly) double currentVelocity;
@property (nonatomic, assign, readonly) double currentPitch;
@property (nonatomic, assign, readonly) double currentVolume;

/**
 * Initialize the audio engine and load audio files.
 * @return Initialized engine instance, or nil if initialization failed
 */
- (instancetype)init;

/**
 * Start the audio engine and begin fart playback.
 */
- (void)startEngine;

/**
 * Stop the audio engine and halt fart playback.
 */
- (void)stopEngine;

/**
 * Update the fart audio based on new lid angle measurement.
 * This method calculates pitch and volume based on angle and movement speed.
 * @param lidAngle Current lid angle in degrees
 */
- (void)updateWithLidAngle:(double)lidAngle;

@end
