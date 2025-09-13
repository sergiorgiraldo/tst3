# Fart-lid

## Howto

Open in Xcode:

```bash
open FartScrollLid.xcodeproj
```

Build and run (Cmd+R)

## Technical Details

### Lid Angle Sensor

- **Device**: Apple HID device (VID=0x05AC, PID=0x8104)
- **HID Usage**: Sensor page (0x0020), Orientation usage (0x008A)
- **Data format**: 16-bit angle value in centidegrees (0.01° resolution)
- **Range**: 0-360 degrees

### Audio Engine

- Uses AVFoundation for real-time audio playback
- Varispeed unit for pitch modulation (0.5x to 2.0x)
- Smooth parameter ramping to avoid audio artifacts
- Movement threshold: 2 deg/s minimum to trigger farts
