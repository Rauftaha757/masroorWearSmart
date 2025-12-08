import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/run_comfy_service.dart';
import '../../models/virtual_try_on_models.dart';

class VirtualTryOnPage extends StatefulWidget {
  const VirtualTryOnPage({Key? key}) : super(key: key);

  @override
  State<VirtualTryOnPage> createState() => _VirtualTryOnPageState();
}

class _VirtualTryOnPageState extends State<VirtualTryOnPage> {
  final ImagePicker _picker = ImagePicker();

  File? _personImage;
  File? _garmentImage;
  ClothType _selectedClothType = ClothType.upper;
  bool _isProcessing = false;
  double _progress = 0.0;
  String? _statusMessage;
  String? _resultImageUrl;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E27),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Virtual Try On',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'How it works',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '1. Select a photo of yourself\n'
                    '2. Select a garment image (clothing item)\n'
                    '3. Choose upper or lower body\n'
                    '4. Tap "Try On" to see the result',
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Person Image Selection
            _buildImageSelector(
              title: 'Person Image',
              image: _personImage,
              onTap: () => _pickImage(ImageSource.gallery, isPerson: true),
            ),

            SizedBox(height: 20.h),

            // Garment Image Selection
            _buildImageSelector(
              title: 'Garment Image',
              image: _garmentImage,
              onTap: () => _pickImage(ImageSource.gallery, isPerson: false),
            ),

            SizedBox(height: 24.h),

            // Cloth Type Selection
            Text(
              'Cloth Type',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildClothTypeOption(
                    type: ClothType.upper,
                    label: 'Upper Body',
                    icon: Icons.checkroom,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildClothTypeOption(
                    type: ClothType.lower,
                    label: 'Lower Body',
                    icon: Icons.accessibility_new,
                  ),
                ),
              ],
            ),

            SizedBox(height: 32.h),

            // Try On Button
            ElevatedButton(
              onPressed: _canTryOn() && !_isProcessing ? _startTryOn : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF74B9FF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                disabledBackgroundColor: Colors.grey.withOpacity(0.3),
              ),
              child: _isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Processing...',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Try On',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            // Progress Indicator
            if (_isProcessing) ...[
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F3A),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF74B9FF),
                      ),
                      minHeight: 8.h,
                    ),
                    if (_statusMessage != null) ...[
                      SizedBox(height: 12.h),
                      Text(
                        _statusMessage!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                    SizedBox(height: 8.h),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Error Message
            if (_error != null) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Colors.red[200],
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Result Image
            if (_resultImageUrl != null) ...[
              SizedBox(height: 24.h),
              Text(
                'Result',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    _resultImageUrl!,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 400.h,
                        color: Colors.grey[900],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 400.h,
                        color: Colors.grey[900],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48.sp,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Failed to load result image',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _resultImageUrl = null;
                    _error = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text('Try Another', style: TextStyle(fontSize: 14.sp)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageSelector({
    required String title,
    File? image,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F3A),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: image != null
                    ? const Color(0xFF74B9FF)
                    : Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.file(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        color: Colors.white.withOpacity(0.5),
                        size: 48.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Tap to select image',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildClothTypeOption({
    required ClothType type,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedClothType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedClothType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF74B9FF).withOpacity(0.2)
              : const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF74B9FF)
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF74B9FF) : Colors.white70,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF74B9FF) : Colors.white70,
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canTryOn() {
    return _personImage != null && _garmentImage != null;
  }

  Future<void> _pickImage(ImageSource source, {required bool isPerson}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          if (isPerson) {
            _personImage = File(image.path);
          } else {
            _garmentImage = File(image.path);
          }
          _error = null;
          _resultImageUrl = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking image: ${e.toString()}';
      });
    }
  }

  Future<void> _startTryOn() async {
    if (!_canTryOn()) return;

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _statusMessage = 'Initializing...';
      _error = null;
      _resultImageUrl = null;
    });

    try {
      final request = VirtualTryOnRequest(
        personImage: _personImage!,
        garmentImage: _garmentImage!,
        clothType: _selectedClothType,
      );

      // Update status messages based on progress
      final resultUrl = await RunComfyService.runTryOn(
        personImage: request.personImage,
        garmentImage: request.garmentImage,
        clothType: request.clothTypeString,
        onProgress: (progress) {
          setState(() {
            _progress = progress;
            if (progress < 0.1) {
              _statusMessage = 'Launching server...';
            } else if (progress < 0.3) {
              _statusMessage = 'Waiting for server to be ready...';
            } else if (progress < 0.5) {
              _statusMessage = 'Uploading images...';
            } else if (progress < 0.7) {
              _statusMessage = 'Processing images...';
            } else if (progress < 0.9) {
              _statusMessage = 'Generating try-on result...';
            } else {
              _statusMessage = 'Finalizing...';
            }
          });
        },
      );

      if (resultUrl != null) {
        setState(() {
          _isProcessing = false;
          _resultImageUrl = resultUrl;
          _statusMessage = null;
        });
      } else {
        throw Exception('No result URL returned');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _error = 'Failed to process try-on: ${e.toString()}';
        _statusMessage = null;
      });
    }
  }
}
