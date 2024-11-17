// import 'dart:async';
// import 'dart:io';
// import 'dart:ui' as ui;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:flutter/services.dart';

// late List<CameraDescription> cameras;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   cameras = await availableCameras();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.dark(),
//       home: const FaceTrackingScreen(),
//     );
//   }
// }

// class FaceTrackingScreen extends StatefulWidget {
//   const FaceTrackingScreen({super.key});

//   @override
//   State<FaceTrackingScreen> createState() => _FaceTrackingScreenState();
// }

// class _FaceTrackingScreenState extends State<FaceTrackingScreen> {
//   late CameraController _cameraController;
//   late FaceDetector _faceDetector;
//   bool _isDetecting = false;
//   List<Face> _faces = [];
//   ui.Image? _glassesImage;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _initializeFaceDetector();
//     _loadGlassesImage();
//   }

//   Future<void> _loadGlassesImage() async {
//     try {
//       final ByteData data = await rootBundle.load('assets/devil.png');
//       final Uint8List bytes = data.buffer.asUint8List();
//       final ui.Codec codec = await ui.instantiateImageCodec(bytes);
//       final ui.FrameInfo fi = await codec.getNextFrame();
//       setState(() {
//         _glassesImage = fi.image;
//       });
//     } catch (e) {
//       print('Error loading glasses image: $e');
//     }
//   }

//   void _initializeCamera() {
//     // Sélection de la caméra frontale
//     final frontCamera = cameras.firstWhere(
//       (camera) => camera.lensDirection == CameraLensDirection.front,
//       orElse: () => cameras[0],
//     );

//     _cameraController = CameraController(
//       frontCamera,
//       ResolutionPreset.medium,
//       enableAudio: false,
//       imageFormatGroup: Platform.isAndroid 
//           ? ImageFormatGroup.bgra8888 
//           : ImageFormatGroup.bgra8888,
//     );

//     _cameraController.initialize().then((_) {
//       if (!mounted) return;
//       setState(() {});
//       _startImageStream();
//     }).catchError((error) {
//       print('Error initializing camera: $error');
//     });
//   }

//   void _initializeFaceDetector() {
//     _faceDetector = FaceDetector(
//       options: FaceDetectorOptions(
//         enableContours: true,
//         enableLandmarks: true,
//         performanceMode: FaceDetectorMode.accurate,
//         enableTracking: true,
//       ),
//     );
//   }

//   void _startImageStream() {
//     _cameraController.startImageStream((CameraImage image) async {
//       if (_isDetecting) return;
//       _isDetecting = true;

//       try {
//         final inputImage = await _processImageToInput(image);
//         final faces = await _faceDetector.processImage(inputImage);
        
//         if (mounted) {
//           setState(() {
//             _faces = faces;
//           });
//         }
//       } catch (e) {
//         print('Error processing image: $e');
//       } finally {
//         _isDetecting = false;
//       }
//     });
//   }

//   Future<InputImage> _processImageToInput(CameraImage image) async {
//     try {
//       final WriteBuffer allBytes = WriteBuffer();
//       for (var plane in image.planes) {
//         allBytes.putUint8List(plane.bytes);
//       }
//       final bytes = allBytes.done().buffer.asUint8List();

//       final imageMetadata = InputImageMetadata(
//         size: Size(image.width.toDouble(), image.height.toDouble()),
//         rotation: InputImageRotation.rotation270deg, // Important pour la caméra frontale
//         format: Platform.isAndroid 
//             ? InputImageFormat.bgra8888 
//             : InputImageFormat.bgra8888,
//         bytesPerRow: image.planes[0].bytesPerRow,
//       );

//       return InputImage.fromBytes(
//         bytes: bytes,
//         metadata: imageMetadata,
//       );
//     } catch (e) {
//       print('Error processing image: $e');
//       rethrow;
//     }
//   }

//   @override
//   void dispose() {
//     _cameraController.dispose();
//     _faceDetector.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_cameraController.value.isInitialized) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           Transform.scale(
//             scaleX: -1,
//             child: CameraPreview(_cameraController),
//           ),
//           if (_faces.isNotEmpty && _glassesImage != null)
//             CustomPaint(
//               size: Size.infinite,
//               painter: FacePainter(
//                 faces: _faces,
//                 glassesImage: _glassesImage!,
//                 previewSize: _cameraController.value.previewSize!,
//                 widgetSize: MediaQuery.of(context).size,
//                 cameraLensDirection: _cameraController.description.lensDirection,
//               ),
//             ),
//           // Debug indicator
//           Positioned(
//             top: 50,
//             left: 20,
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.black54,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 'Faces détectées: ${_faces.length}',
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class FacePainter extends CustomPainter {
//   final List<Face> faces;
//   final ui.Image glassesImage;
//   final Size previewSize;
//   final Size widgetSize;
//   final CameraLensDirection cameraLensDirection;

//   FacePainter({
//     required this.faces,
//     required this.glassesImage,
//     required this.previewSize,
//     required this.widgetSize,
//     required this.cameraLensDirection,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final double scaleX = widgetSize.width / previewSize.width;
//     final double scaleY = widgetSize.height / previewSize.height;

//     final Paint paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0
//       ..color = Colors.red;

//     for (final Face face in faces) {
//       final left = face.boundingBox.left.toDouble();
//       final top = face.boundingBox.top.toDouble();
//       final right = face.boundingBox.right.toDouble();
//       final bottom = face.boundingBox.bottom.toDouble();

//       // Calcul de la largeur et hauteur du visage
//       final double faceWidth = (right - left).abs().toDouble();
//       final double faceHeight = (bottom - top).abs().toDouble();

//       // Calculer le vrai centre du visage
//       final double faceCenterX = (right + left) / 1.5;
      
//       // Position ajustée pour la caméra frontale
//       final double adjustedX = cameraLensDirection == CameraLensDirection.front
//           ? widgetSize.width - (faceCenterX * scaleX)
//           : faceCenterX * scaleX;

//       // Calculer le centre vertical du visage
//       final double faceCenterY = (top + bottom) / 3;

//       // Ajuster la taille du masque
//       final double maskWidth = faceWidth * 1.9;
//       final double maskHeight = faceHeight * 1.3;

//       // Ajuster la position verticale
//       final double adjustedY = faceCenterY * scaleY;

//       // Dessiner le masque
//       canvas.drawImageRect(
//         glassesImage,
//         Rect.fromLTWH(0, 0, glassesImage.width.toDouble(), glassesImage.height.toDouble()),
//         Rect.fromCenter(
//           center: Offset(adjustedX, adjustedY),
//           width: maskWidth * scaleX,
//           height: maskHeight * scaleY,
//         ),
//         Paint(),
//       );

//       // Rectangle de débogage pour visualiser la zone de détection
//       if (cameraLensDirection == CameraLensDirection.front) {
//         canvas.drawRect(
//           Rect.fromCenter(
//             center: Offset(adjustedX, adjustedY),
//             width: faceWidth * scaleX,
//             height: faceHeight * scaleY,
//           ),
//           paint,
//         );
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(FacePainter oldDelegate) {
//     return oldDelegate.faces != faces;
//   }
// }
