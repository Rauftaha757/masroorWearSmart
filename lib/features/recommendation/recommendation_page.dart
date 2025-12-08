import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/services/wearsmart_api_service.dart';
import '../../core/services/weather_service.dart';
import '../../models/recommendation_models.dart';

class RecommendationPage extends StatefulWidget {
  final String? gender; // 'men' or 'women'
  final WeatherData? weatherData;

  const RecommendationPage({Key? key, this.gender, this.weatherData})
    : super(key: key);

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  final WearSmartApiService _apiService = WearSmartApiService();
  bool _isLoading = false;
  OutfitResponse? _recommendation;
  Map<String, List<String>> _recommendedImages = {};
  Map<String, bool> _categoryLoading = {}; // Track loading state per category
  String? _error;
  String _selectedGender = 'men';
  String _selectedOccasion = 'casual';
  String _selectedTimeOfDay = 'afternoon';
  String _selectedSeason = 'summer';
  String? _selectedMood;

  // Selected alternatives for each category
  String? _selectedTopCategory;
  String? _selectedBottomCategory;
  String? _selectedOuterCategory;

  // Mapping of categories to local asset images
  Map<String, List<String>> _categoryAssetImages = {
    // Top categories
    'shirt': [
      'assets/images/formal_shirt.jpg',
      'assets/images/s1.jpg',
      'assets/images/s2.jpg',
    ],
    't-shirt': [
      'assets/images/s3.jpg',
      'assets/images/s4.jpg',
      'assets/images/s5.jpg',
    ],
    't shirt': [
      'assets/images/s3.jpg',
      'assets/images/s4.jpg',
      'assets/images/s5.jpg',
    ],
    'hoodie': [
      'assets/images/h1.jpg',
      'assets/images/h2.jpg',
      'assets/images/h3.jpg',
      'assets/images/h4.jpg',
    ],
    'sweater': ['assets/images/s6.jpg'],
    'top': ['assets/images/s1.jpg', 'assets/images/s2.jpg'],

    // Bottom categories
    'jeans': [
      'assets/images/jean1.webp',
      'assets/images/jean2.webp',
      'assets/images/jean3.webp',
    ],
    'trousers': [
      'assets/images/dress_pant.jpg',
      'assets/images/dress_pant_2.jpg',
      'assets/images/dress_pant_3.jpg',
    ],
    'pants': [
      'assets/images/p1.jpg',
      'assets/images/p2.jpg',
      'assets/images/p3.jpg',
      'assets/images/p4.jpg',
    ],
    'leggings': [], // Will be added when user provides images
    'capris': ['assets/images/p1.jpg', 'assets/images/p2.jpg'],

    // Outer categories
    'jacket': [
      'assets/images/j1.jpg',
      'assets/images/j2.jpg',
      'assets/images/j3.jpg',
      'assets/images/j4.jpg',
    ],
    'coat': [
      'assets/images/coat.jpg',
      'assets/images/coat2.jpg',
      'assets/images/coat3.jpg',
    ],
    'kurta': [
      'assets/images/k1.jpg',
      'assets/images/k2.jpg',
      'assets/images/k3.jpg',
      'assets/images/k4.jpg',
    ],
  };

  // Available categories for dropdowns (normalized to lowercase)
  final List<String> _topCategories = [
    'shirt',
    't-shirt',
    't shirt',
    'hoodie',
    'sweater',
    'tank top',
    'polo',
    'blouse',
    'top',
  ];
  final List<String> _bottomCategories = [
    'jeans',
    'trousers',
    'pants',
    'shorts',
    'skirt',
    'leggings',
    'capris',
  ];
  final List<String> _outerCategories = [
    'jacket',
    'coat',
    'blazer',
    'hoodie',
    'cardigan',
    'puffer jacket',
    'puffer_jacket',
    'windbreaker',
  ];

  // Helper method to normalize category names
  String _normalizeCategory(String category) {
    return category.toLowerCase().trim();
  }

  // Helper method to find matching category in list
  String? _findMatchingCategory(String category, List<String> options) {
    final normalized = _normalizeCategory(category);

    // First try exact match
    for (final option in options) {
      if (_normalizeCategory(option) == normalized) {
        return option;
      }
    }

    // Try partial match (e.g., "T-Shirt" matches "t-shirt")
    for (final option in options) {
      final optionNormalized = _normalizeCategory(option);
      if (normalized.contains(optionNormalized) ||
          optionNormalized.contains(normalized)) {
        return option;
      }
    }

    // If no match found, return the normalized version if it exists in options
    if (options.contains(normalized)) {
      return normalized;
    }

    // Return first option as fallback
    return options.isNotEmpty ? options.first : null;
  }

  // Default weather values if not provided
  double _temperature = 25.0;
  double _feelsLike = 26.0;
  double _humidity = 60.0;
  double _windSpeed = 10.0;
  String _weatherCondition = 'clear';

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.gender ?? 'men';
    _initializeWeatherData();
  }

  void _initializeWeatherData() {
    if (widget.weatherData != null) {
      _temperature = widget.weatherData!.tempC;
      _feelsLike = widget.weatherData!.feelsLike;
      _humidity = widget.weatherData!.humidity;
      _windSpeed = widget.weatherData!.windSpeed;
      _weatherCondition = _mapWeatherCondition(widget.weatherData!.description);
      _selectedSeason = _determineSeason(_temperature);
      _selectedTimeOfDay = _getCurrentTimeOfDay();
    }
  }

  String _mapWeatherCondition(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('clear') || desc.contains('sunny')) {
      return 'clear';
    } else if (desc.contains('cloud')) {
      return 'clouds';
    } else if (desc.contains('rain')) {
      return 'rain';
    } else if (desc.contains('snow')) {
      return 'snow';
    } else if (desc.contains('fog') || desc.contains('mist')) {
      return 'fog';
    } else {
      return 'clear';
    }
  }

  String _determineSeason(double temp) {
    // Simple season determination based on temperature
    if (temp >= 30) return 'summer';
    if (temp >= 20) return 'spring';
    if (temp >= 10) return 'autumn';
    return 'winter';
  }

  String _getCurrentTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  Future<void> _getRecommendation() async {
    print('\n');
    print('╔══════════════════════════════════════════════════════════════╗');
    print('║         GETTING RECOMMENDATION - USER ACTION                ║');
    print('╚══════════════════════════════════════════════════════════════╝');
    print('👤 Gender: $_selectedGender');
    print('🌡️  Temperature: $_temperature°C');
    print('🌡️  Feels Like: $_feelsLike°C');
    print('💧 Humidity: $_humidity%');
    print('💨 Wind Speed: $_windSpeed m/s');
    print('☁️  Weather Condition: $_weatherCondition');
    print('⏰ Time of Day: $_selectedTimeOfDay');
    print('🍂 Season: $_selectedSeason');
    print('🎉 Occasion: $_selectedOccasion');
    if (_selectedGender == 'men' && _selectedMood != null) {
      print('😊 Mood: $_selectedMood');
    }
    print('═══════════════════════════════════════════════════════════════\n');

    setState(() {
      _isLoading = true;
      _error = null;
      _recommendation = null;
      _recommendedImages.clear();
    });

    try {
      OutfitResponse recommendation;

      if (_selectedGender == 'men') {
        final request = MenRecommendationRequest(
          temperature: _temperature,
          feelsLike: _feelsLike,
          humidity: _humidity,
          windSpeed: _windSpeed,
          weatherCondition: _weatherCondition,
          timeOfDay: _selectedTimeOfDay,
          season: _selectedSeason,
          mood: _selectedMood,
          occasion: _selectedOccasion,
        );
        recommendation = await _apiService.getMenRecommendation(request);
      } else {
        final request = WomenRecommendationRequest(
          temperature: _temperature,
          feelsLike: _feelsLike,
          humidity: _humidity,
          windSpeed: _windSpeed,
          weatherCondition: _weatherCondition,
          timeOfDay: _selectedTimeOfDay,
          season: _selectedSeason,
          occasion: _selectedOccasion,
        );
        recommendation = await _apiService.getWomenRecommendation(request);
      }

      print('\n');
      print('╔══════════════════════════════════════════════════════════════╗');
      print(
        '║         FETCHING IMAGES FOR RECOMMENDATIONS                   ║',
      );
      print('╚══════════════════════════════════════════════════════════════╝');
      print('👕 Top: ${recommendation.top}');
      print('👖 Bottom: ${recommendation.bottom}');
      print('🧥 Outer: ${recommendation.outer}');
      print(
        '═══════════════════════════════════════════════════════════════\n',
      );

      // Fetch images for each recommended category
      final topImages = await _apiService.getCloudImages(
        gender: _selectedGender,
        label: recommendation.top,
        limit: 5,
      );
      final bottomImages = await _apiService.getCloudImages(
        gender: _selectedGender,
        label: recommendation.bottom,
        limit: 5,
      );
      final outerImages = await _apiService.getCloudImages(
        gender: _selectedGender,
        label: recommendation.outer,
        limit: 5,
      );

      print('\n');
      print('╔══════════════════════════════════════════════════════════════╗');
      print('║         RECOMMENDATION COMPLETE                              ║');
      print('╚══════════════════════════════════════════════════════════════╝');
      print('✅ Top images: ${topImages.images.length}');
      print('✅ Bottom images: ${bottomImages.images.length}');
      print('✅ Outer images: ${outerImages.images.length}');
      print(
        '═══════════════════════════════════════════════════════════════\n',
      );

      // Extract image URLs
      final topUrls = topImages.images.map((img) => img.url).toList();
      final bottomUrls = bottomImages.images.map((img) => img.url).toList();
      final outerUrls = outerImages.images.map((img) => img.url).toList();

      // Log extracted URLs
      print('📸 Extracted Image URLs:');
      print('   Top URLs (${topUrls.length}):');
      topUrls.forEach((url) => print('     - $url'));
      print('   Bottom URLs (${bottomUrls.length}):');
      bottomUrls.forEach((url) => print('     - $url'));
      print('   Outer URLs (${outerUrls.length}):');
      outerUrls.forEach((url) => print('     - $url'));
      print('');

      setState(() {
        _recommendation = recommendation;
        _recommendedImages = {
          'top': topUrls,
          'bottom': bottomUrls,
          'outer': outerUrls,
        };
        // Set initial selected categories to recommended ones (normalized)
        _selectedTopCategory = _findMatchingCategory(
          recommendation.top,
          _topCategories,
        );
        _selectedBottomCategory = _findMatchingCategory(
          recommendation.bottom,
          _bottomCategories,
        );
        _selectedOuterCategory = _findMatchingCategory(
          recommendation.outer,
          _outerCategories,
        );
      });
    } catch (e) {
      print('\n');
      print('╔══════════════════════════════════════════════════════════════╗');
      print('║         ERROR GETTING RECOMMENDATION                        ║');
      print('╚══════════════════════════════════════════════════════════════╝');
      print('❌ Error: $e');
      print(
        '═══════════════════════════════════════════════════════════════\n',
      );

      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Outfit Recommendations'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings Section
            _buildSettingsSection(),

            SizedBox(height: 24.h),

            // Recommendation Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _getRecommendation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Get Recommendations',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 24.h),

            // Error Display
            if (_error != null) _buildErrorWidget(),

            // Recommendations Display
            if (_recommendation != null) _buildRecommendationsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.w,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          _buildDropdown(
            'Gender',
            _selectedGender,
            ['men', 'women'],
            (value) => setState(() => _selectedGender = value!),
          ),
          SizedBox(height: 12.h),
          _buildDropdown(
            'Occasion',
            _selectedOccasion,
            ['casual', 'formal', 'sports', 'party'],
            (value) => setState(() => _selectedOccasion = value!),
          ),
          SizedBox(height: 12.h),
          _buildDropdown(
            'Time of Day',
            _selectedTimeOfDay,
            ['morning', 'afternoon', 'evening', 'night'],
            (value) => setState(() => _selectedTimeOfDay = value!),
          ),
          SizedBox(height: 12.h),
          _buildDropdown(
            'Season',
            _selectedSeason,
            ['spring', 'summer', 'autumn', 'winter'],
            (value) => setState(() => _selectedSeason = value!),
          ),
          if (_selectedGender == 'men') ...[
            SizedBox(height: 12.h),
            _buildDropdown(
              'Mood',
              _selectedMood ?? 'Neutral',
              ['Neutral', 'good', 'bad'],
              (value) => setState(() => _selectedMood = value),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4.h),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item[0].toUpperCase() + item.substring(1)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.w),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(_error!, style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Outfit',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        _buildCategorySection(
          'Top',
          _recommendation!.top,
          _recommendedImages['top'] ?? [],
        ),
        SizedBox(height: 16.h),
        _buildCategorySection(
          'Bottom',
          _recommendation!.bottom,
          _recommendedImages['bottom'] ?? [],
        ),
        SizedBox(height: 16.h),
        _buildCategorySection(
          'Outer',
          _recommendation!.outer,
          _recommendedImages['outer'] ?? [],
        ),
      ],
    );
  }

  Widget _buildCategorySection(
    String title,
    String category,
    List<String> imageUrls,
  ) {
    // Determine which dropdown to show and current selection
    String? currentSelection;
    List<String> dropdownOptions = [];
    Function(String?)? onChanged;

    if (title == 'Top') {
      final matchedCategory = _findMatchingCategory(
        _selectedTopCategory ?? category,
        _topCategories,
      );
      currentSelection = matchedCategory ?? _topCategories.first;
      dropdownOptions = _topCategories;
      onChanged = (value) => _onCategoryChanged('top', value);
    } else if (title == 'Bottom') {
      final matchedCategory = _findMatchingCategory(
        _selectedBottomCategory ?? category,
        _bottomCategories,
      );
      currentSelection = matchedCategory ?? _bottomCategories.first;
      dropdownOptions = _bottomCategories;
      onChanged = (value) => _onCategoryChanged('bottom', value);
    } else if (title == 'Outer') {
      final matchedCategory = _findMatchingCategory(
        _selectedOuterCategory ?? category,
        _outerCategories,
      );
      currentSelection = matchedCategory ?? _outerCategories.first;
      dropdownOptions = _outerCategories;
      onChanged = (value) => _onCategoryChanged('outer', value);
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.w,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$title:',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: currentSelection,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: dropdownOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(
                        option
                            .split(' ')
                            .map(
                              (word) =>
                                  word[0].toUpperCase() + word.substring(1),
                            )
                            .join(' ')
                            .replaceAll('_', ' '),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Show loading indicator when fetching new images for this category
          Builder(
            builder: (context) {
              String categoryKey = title.toLowerCase();
              bool isLoadingCategory = _categoryLoading[categoryKey] ?? false;

              if (isLoadingCategory && imageUrls.isEmpty) {
                return Container(
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16.h),
                        Text(
                          'Loading images for $currentSelection...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (imageUrls.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 48.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'No images available for $currentSelection',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              } else {
                return SizedBox(
                  height: 200.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 160.w,
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.w),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.w),
                          child: _buildImageWidget(imageUrls[index]),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _onCategoryChanged(
    String categoryType,
    String? newCategory,
  ) async {
    if (newCategory == null) return;

    // Don't fetch if it's the same category
    String? currentCategory;
    if (categoryType == 'top') {
      currentCategory = _selectedTopCategory;
    } else if (categoryType == 'bottom') {
      currentCategory = _selectedBottomCategory;
    } else if (categoryType == 'outer') {
      currentCategory = _selectedOuterCategory;
    }

    if (_normalizeCategory(currentCategory ?? '') ==
        _normalizeCategory(newCategory)) {
      print('⚠️ Same category selected, skipping fetch');
      return;
    }

    // Set loading state for this specific category
    setState(() {
      _categoryLoading[categoryType] = true;
      _error = null; // Clear previous errors
    });

    try {
      print('\n🔄 Changing $categoryType category to: $newCategory');

      // Update selected category immediately for better UX
      if (categoryType == 'top') {
        _selectedTopCategory = newCategory;
      } else if (categoryType == 'bottom') {
        _selectedBottomCategory = newCategory;
      } else if (categoryType == 'outer') {
        _selectedOuterCategory = newCategory;
      }

      // First, try to get local asset images
      final normalizedCategory = _normalizeCategory(newCategory);
      final assetImages =
          _categoryAssetImages[normalizedCategory] ??
          _categoryAssetImages[newCategory] ??
          [];

      List<String> imageUrls = [];

      // Use local assets if available
      if (assetImages.isNotEmpty) {
        print(
          '📦 Using local asset images for $newCategory: ${assetImages.length} images',
        );
        imageUrls = List.from(assetImages);
      }

      // Also try to fetch from API as fallback or addition
      try {
        print('📡 Fetching images from API for $categoryType: $newCategory');
        final newImages = await _apiService.getCloudImages(
          gender: _selectedGender,
          label: newCategory,
          limit: 10,
        );

        final apiUrls = newImages.images.map((img) => img.url).toList();
        print('✅ Fetched ${apiUrls.length} images from API for $newCategory');

        // Combine: use assets first, then add API images
        if (assetImages.isNotEmpty) {
          imageUrls = [...assetImages, ...apiUrls];
        } else {
          imageUrls = apiUrls;
        }
      } catch (apiError) {
        print('⚠️ API fetch failed, using only local assets: $apiError');
        // If API fails but we have assets, use assets
        if (assetImages.isEmpty) {
          throw apiError; // Only throw if we have no assets
        }
      }

      print('✅ Total images available for $newCategory: ${imageUrls.length}');

      setState(() {
        _recommendedImages[categoryType] = imageUrls;
        _categoryLoading[categoryType] = false;
      });
    } catch (e) {
      print('❌ Error fetching images for $newCategory: $e');
      setState(() {
        _categoryLoading[categoryType] = false;
        _error = 'Failed to load images for $newCategory. Please try again.';
      });
    }
  }

  // Build image widget - handles both asset and network images
  Widget _buildImageWidget(String imagePath) {
    // Check if it's an asset image (starts with 'assets/')
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: 160.w,
        height: 200.h,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading asset image: $imagePath');
          return Container(
            width: 160.w,
            height: 200.h,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.grey[400], size: 40.sp),
                SizedBox(height: 8.h),
                Text(
                  'Asset not found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Network image
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: 160.w,
        height: 200.h,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading network image: $imagePath');
          print('   Error: $error');
          return Container(
            width: 160.w,
            height: 200.h,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.grey[400], size: 40.sp),
                SizedBox(height: 8.h),
                Text(
                  'Failed to load',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                ),
              ],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            print('✅ Network image loaded: $imagePath');
            return child;
          }
          return Container(
            width: 160.w,
            height: 200.h,
            color: Colors.grey[200],
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
      );
    }
  }
}
