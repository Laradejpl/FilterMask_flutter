# mlkit_fluter

A new Flutter project.
# Face Tracking Flutter App

## Description
This Flutter application implements real-time face tracking using the device's front camera. It detects faces and overlays a customizable devil mask on each detected face. The app uses Google ML Kit for face detection and provides a smooth, real-time experience.

## Features
- Real-time face detection
- Devil mask overlay on detected faces
- Front camera support
- Face tracking counter
- Mirror effect for selfie view

## Prerequisites
- Flutter SDK
- Android Studio or VS Code
- iOS/Android device or emulator
- Minimum iOS 11.0 / Android API level 21

## Dependencies
Add these dependencies to your `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^[latest_version]
  google_mlkit_face_detection: ^[latest_version]
```

## Setup

1. Clone the repository:
```bash
git clone [your-repository-url]
```

2. Install dependencies:
```bash
flutter pub get
```

3. Add the devil mask image:
   - Create an `assets` folder in your project root
   - Add your devil mask image (named `devil.png`)
   - Update `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/devil.png
```

4. Add camera permissions:

### For iOS
Add these lines to your `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for face tracking</string>
```

### For Android
Add this permission to your `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

## Usage
1. Launch the app
2. Grant camera permissions when prompted
3. Point the front camera at faces
4. Watch as the devil mask overlay appears on detected faces
5. The face counter in the top-left shows the number of faces currently detected

## Project Structure
- `main.dart`: Entry point and app initialization
- `FaceTrackingScreen`: Main screen handling camera and face detection
- `FacePainter`: Custom painter for rendering face overlays

## Performance Considerations
- The app uses `ResolutionPreset.medium` for optimal performance
- Face detection is performed on every frame
- Image processing is done in an async manner to prevent UI blocking

## Known Limitations
- Requires good lighting conditions for optimal face detection
- Performance may vary on different devices
- Front camera only implementation

## Contributing
Feel free to submit issues and enhancement requests!




## Credits
- Google ML Kit for face detection
- Flutter Camera plugin
- [laradeJpl]# FilterMask_flutter
