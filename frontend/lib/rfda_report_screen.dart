import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:convert';
import 'simple_language_service.dart';
import 'theme.dart';
import 'widgets/academic_disclaimer.dart';

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
      // Try to access cameras first - this is the most reliable way to check permissions on iOS
      List<CameraDescription> cameras;
      try {
        cameras = await availableCameras();
        debugPrint('Available cameras: ${cameras.length}');
      } catch (e) {
        debugPrint('Error getting cameras: $e');
        
        // If camera access fails, check and request permissions
        PermissionStatus cameraStatus = await Permission.camera.status;
        debugPrint('Camera permission status after error: $cameraStatus');
        
        if (!cameraStatus.isGranted) {
          if (cameraStatus.isPermanentlyDenied) {
            setState(() {
              _error = 'Camera permission is permanently denied. Please enable it in Settings > Medguard > Camera.';
            });
            // Offer to open settings
            try {
              await openAppSettings();
            } catch (_) {
              // Ignore if settings can't be opened
            }
            return;
          }
          
          // Request permission
          cameraStatus = await Permission.camera.request();
          debugPrint('Camera permission after request: $cameraStatus');
          
          // Re-check status after request
          cameraStatus = await Permission.camera.status;
          debugPrint('Camera permission re-checked: $cameraStatus');
          
          if (!cameraStatus.isGranted) {
            setState(() {
              _error = 'Camera permission is required. Please grant camera permission in your device settings.';
            });
            return;
          }
          
          // Try again after granting permission
          try {
            cameras = await availableCameras();
            debugPrint('Available cameras after permission grant: ${cameras.length}');
          } catch (e2) {
            debugPrint('Error getting cameras after permission: $e2');
            setState(() {
              _error = 'Unable to access camera. Please restart the app after granting permission.';
            });
            return;
          }
        } else {
          // Permission is granted but camera access failed - might be in use
          setState(() {
            _error = 'Unable to access camera. Please ensure camera is not being used by another app.';
          });
          return;
        }
      }
      
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

      try {
        await controller.initialize();
        
        // Verify controller is actually initialized
        if (!controller.value.isInitialized) {
          await controller.dispose();
          setState(() {
            _error = 'Camera failed to initialize. Please try again.';
          });
          return;
        }
      } catch (e) {
        try {
          await controller.dispose();
        } catch (_) {
          // Ignore disposal errors
        }
        debugPrint('Error initializing camera: $e');
        
        // Check if it's a permission error
        if (e.toString().toLowerCase().contains('permission') || 
            e.toString().toLowerCase().contains('access')) {
          setState(() {
            _error = 'Camera access denied. Please grant camera permission in Settings > Medguard > Camera.';
          });
          return;
        }
        
        setState(() {
          _error = 'Unable to initialize camera. Please try again.';
        });
        return;
      }

      if (!mounted) {
        try {
          await controller.dispose();
        } catch (_) {
          // Ignore disposal errors
        }
        return;
      }

      // Show camera preview and capture
      XFile? capturedImage;
      try {
        final result = await Navigator.push<XFile>(
          context,
          MaterialPageRoute(
            builder: (context) => _CameraPreview(
              controller: controller,
            ),
          ),
        );
        capturedImage = result;
      } catch (e) {
        debugPrint('Error in camera preview: $e');
      } finally {
        // Always dispose controller after preview is closed
        try {
          if (controller.value.isInitialized) {
            await controller.dispose();
          }
        } catch (e) {
          debugPrint('Error disposing controller: $e');
        }
      }

      if (capturedImage != null && mounted) {
        setState(() {
          _capturedImage = capturedImage;
          _error = null; // Clear any previous errors
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _takePhoto: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _error = 'Error taking photo: ${e.toString()}. Please ensure camera permissions are granted in Settings.';
        });
      }
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
      final languageService = Provider.of<SimpleLanguageService>(context, listen: false);
      
      // Get Supabase client
      final supabase = Supabase.instance.client;
      
      // Upload photo to Supabase Storage
      String? photoUrl;
      try {
        // Read image file
        final imageFile = File(_capturedImage!.path);
        final imageBytes = await imageFile.readAsBytes();
        final imageBase64 = base64Encode(imageBytes);
        
        // Generate unique filename
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'report_${widget.drugData['gtin'] ?? 'unknown'}_$timestamp.jpg';
        
        // Try to upload to storage bucket 'reports' (create if doesn't exist)
        try {
          // Upload to storage
          await supabase.storage
              .from('reports')
              .uploadBinary(
                fileName,
                imageBytes,
                fileOptions: const FileOptions(
                  contentType: 'image/jpeg',
                  upsert: false,
                ),
              );
          
          // Get public URL
          photoUrl = supabase.storage.from('reports').getPublicUrl(fileName);
          debugPrint('✅ Photo uploaded to storage: $photoUrl');
        } catch (storageError) {
          debugPrint('⚠️ Storage upload failed, using base64: $storageError');
          // Fallback: Store as base64 data URL if storage fails
          photoUrl = 'data:image/jpeg;base64,$imageBase64';
        }
      } catch (e) {
        debugPrint('Error processing image: $e');
        // Continue without photo URL
      }
      
      // Prepare report data
      final googleMapsLink = 'https://maps.google.com/?q=${_currentPosition!.latitude},${_currentPosition!.longitude}';
      
      final reportData = {
        'gtin': widget.drugData['gtin'] ?? '',
        'product_name': widget.drugData['product'] ?? widget.drugData['product_name'] ?? '',
        'product': widget.drugData['product'] ?? '',
        'generic_name': widget.drugData['genericName'] ?? widget.drugData['generic_name'] ?? '',
        'manufacturer': widget.drugData['manufacturer'] ?? '',
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'address': _address ?? '',
        'google_maps_link': googleMapsLink,
        'photo_url': photoUrl ?? '',
        'notes': 'Report submitted via MedGuard App. Drug not found in RFDA database during verification.',
        'status': 'pending',
      };
      
      debugPrint('📤 Submitting report to Supabase: $reportData');
      
      // Insert report into Supabase
      final response = await supabase
          .from('reports')
          .insert(reportData)
          .select()
          .single();
      
      debugPrint('✅ Report submitted successfully: ${response['id']}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(languageService.reportSent ?? 'Report submitted successfully'),
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
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
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
          ),
          const AcademicDisclaimer(),
        ],
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
  bool _isInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _checkInitialization();
  }

  Future<void> _checkInitialization() async {
    if (widget.controller.value.isInitialized) {
      setState(() {
        _isInitialized = true;
      });
    } else {
      // Wait a bit for initialization
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted && widget.controller.value.isInitialized) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Don't dispose controller here - parent will handle it
    super.dispose();
  }

  Future<void> _handleClose() async {
    if (!_isDisposed && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleCapture() async {
    if (_isDisposed || !widget.controller.value.isInitialized) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    try {
      final image = await widget.controller.takePicture();
      if (mounted && !_isDisposed) {
        Navigator.pop(context, image);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      if (mounted && !_isDisposed) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || !widget.controller.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(widget.controller),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              onPressed: _handleClose,
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
                onPressed: _handleCapture,
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
