import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'simple_language_service.dart';
import 'theme.dart';

class RFDAReportScreen extends StatefulWidget {
  final Map<String, dynamic> drugData;

  const RFDAReportScreen({
    super.key,
    required this.drugData,
  });

  @override
  State<RFDAReportScreen> createState() => _RFDAReportScreenState();
}

class _RFDAReportScreenState extends State<RFDAReportScreen> {
  Position? _currentPosition;
  XFile? _capturedImage;
  bool _isLoading = false;
  String? _error;
  String? _address;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled.';
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permissions are denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permissions are permanently denied';
        });
        return;
      }

      // Get current position with best accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 30),
      );

      // Get address from coordinates
      String? address = await _getAddressFromCoordinates(
        position.latitude, 
        position.longitude
      );

      setState(() {
        _currentPosition = position;
        _address = address;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Error getting location: $e';
      });
    }
  }

  Future<String?> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      // Using OpenStreetMap Nominatim for reverse geocoding (free service)
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1'),
        headers: {'User-Agent': 'MedGuard App'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['display_name'] as String?;
        return address;
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    return null;
  }

  Future<void> _takePhoto() async {
    try {
      // Request camera permission explicitly
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        setState(() {
          _error = 'Camera permission is required to take a photo. Please grant camera permission in settings.';
        });
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _error = 'No cameras available';
        });
        return;
      }

      final camera = cameras.first;
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) return;

      // Show camera preview and capture
      final image = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _CameraPreview(
            controller: controller,
          ),
        ),
      );

      if (image != null) {
        setState(() {
          _capturedImage = image;
          _error = null; // Clear any previous errors
        });
      }

      await controller.dispose();
    } catch (e) {
      setState(() {
        _error = 'Error taking photo: $e. Please ensure camera permissions are granted.';
      });
    }
  }

  Future<void> _sendReport() async {
    if (_currentPosition == null) {
      setState(() {
        _error = 'Location is required to send report';
      });
      return;
    }

    if (_capturedImage == null) {
      setState(() {
        _error = 'Photo is required to send report';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Create email content
      final languageService = Provider.of<SimpleLanguageService>(context, listen: false);
      
      final subject = 'RFDA Report - Unverified Drug: ${widget.drugData['gtin'] ?? 'Unknown'}';
      final body = '''
RFDA Drug Verification Report

Drug Information:
- GTIN: ${widget.drugData['gtin'] ?? 'Unknown'}
- Product: ${widget.drugData['product'] ?? 'Unknown'}
- Generic Name: ${widget.drugData['genericName'] ?? 'Unknown'}
- Manufacturer: ${widget.drugData['manufacturer'] ?? 'Unknown'}

Location Information:
- Latitude: ${_currentPosition!.latitude}
- Longitude: ${_currentPosition!.longitude}
- Accuracy: ${_currentPosition!.accuracy} meters
- Address: ${_address ?? 'Address not available'}
- Google Maps Link: https://maps.google.com/?q=${_currentPosition!.latitude},${_currentPosition!.longitude}
- Timestamp: ${DateTime.now().toIso8601String()}

Report Details:
This drug was not found in the RFDA database during verification.
Please investigate and update the database if this is a legitimate registered medicine.

Report submitted via MedGuard App.
      ''';

      // Method 1: Try to use flutter_email_sender for direct email with attachment
      bool emailSent = false;
      try {
        final Email email = Email(
          body: body,
          subject: subject,
          recipients: ['a.oshingbes@alustudent.com'],
          attachmentPaths: [_capturedImage!.path],
          isHTML: false,
        );

        await FlutterEmailSender.send(email);
        emailSent = true;
      } catch (e) {
        debugPrint('FlutterEmailSender failed: $e');
        
        // Method 2: Fallback to share functionality with email intent
        try {
          // Try to share with email intent
          final emailUrl = Uri(
            scheme: 'mailto',
            path: 'a.oshingbes@alustudent.com',
            query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
          );

          if (await canLaunchUrl(emailUrl)) {
            await launchUrl(emailUrl, mode: LaunchMode.externalApplication);
            emailSent = true;
            // Also share the image separately so user can attach it
            await Future.delayed(const Duration(seconds: 1)); // Give email client time to open
            await Share.shareXFiles(
              [XFile(_capturedImage!.path)],
              text: 'Please attach this image to your email to a.oshingbes@alustudent.com',
            );
          } else {
            // Method 3: Final fallback - share everything
            await Share.shareXFiles(
              [XFile(_capturedImage!.path)],
              text: '$body\n\nPlease send this report to: a.oshingbes@alustudent.com',
              subject: subject,
            );
            emailSent = true;
          }
        } catch (e2) {
          debugPrint('Email sharing failed: $e2');
          setState(() {
            _error = 'Could not open email client. Error: $e2. Please manually send email to a.oshingbes@alustudent.com';
          });
          return;
        }
      }
      
      if (!emailSent) {
        setState(() {
          _error = 'Failed to send email. Please manually send the report to a.oshingbes@alustudent.com';
        });
        return;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(languageService.reportSent),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to send report: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<SimpleLanguageService>(context);

    return Scaffold(
      backgroundColor: kAppBg,
      appBar: AppBar(
        backgroundColor: kAppBg,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 16, color: Colors.black87),
          label: Text(languageService.back,
              style: const TextStyle(color: Colors.black)),
        ),
        title: Text(
          languageService.reportUnverifiedDrug,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drug Information Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.medication,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          languageService.drugInformation,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _infoRow('GTIN', widget.drugData['gtin'] ?? 'Unknown'),
                    _infoRow('Product', widget.drugData['product'] ?? 'Unknown'),
                    _infoRow('Generic Name', widget.drugData['genericName'] ?? 'Unknown'),
                    _infoRow('Manufacturer', widget.drugData['manufacturer'] ?? 'Unknown'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Location Section
              _LocationSection(
                position: _currentPosition,
                address: _address,
                onGetLocation: _getCurrentLocation,
                languageService: languageService,
              ),

              const SizedBox(height: 24),

              // Photo Section
              _PhotoSection(
                capturedImage: _capturedImage,
                onTakePhoto: _takePhoto,
                languageService: languageService,
              ),

              const SizedBox(height: 24),

              // Error Display
              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Send Report Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.orange.shade600, Colors.orange.shade700],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _isLoading ? null : _sendReport,
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  languageService.sendReport,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  final Position? position;
  final String? address;
  final VoidCallback onGetLocation;
  final SimpleLanguageService languageService;

  const _LocationSection({
    required this.position,
    required this.address,
    required this.onGetLocation,
    required this.languageService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                languageService.getLocation,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (position != null) ...[
            _infoRow('Latitude', position!.latitude.toStringAsFixed(6)),
            _infoRow('Longitude', position!.longitude.toStringAsFixed(6)),
            _infoRow('Accuracy', '${position!.accuracy.toStringAsFixed(1)} meters'),
            if (address != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, color: Colors.blue.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            Text(
              languageService.locationNotAvailable,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onGetLocation,
              icon: const Icon(Icons.my_location, size: 18),
              label: Text(languageService.getLocation),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  final XFile? capturedImage;
  final VoidCallback onTakePhoto;
  final SimpleLanguageService languageService;

  const _PhotoSection({
    required this.capturedImage,
    required this.onTakePhoto,
    required this.languageService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.camera_alt,
                color: Colors.green.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                languageService.takePhoto,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (capturedImage != null) ...[
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(capturedImage!.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    languageService.photoNotTaken,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTakePhoto,
              icon: const Icon(Icons.camera_alt, size: 18),
              label: Text(languageService.takePhoto),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraPreview extends StatefulWidget {
  final CameraController controller;

  const _CameraPreview({required this.controller});

  @override
  State<_CameraPreview> createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<_CameraPreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(widget.controller),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: () async {
                  final image = await widget.controller.takePicture();
                  if (mounted) {
                    Navigator.pop(context, image);
                  }
                },
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
