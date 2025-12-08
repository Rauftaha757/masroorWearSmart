import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/clothing_item.dart';
import '../../models/local_clothing_item.dart';
import '../../core/services/database_helper.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/weather_service.dart';
import '../../core/services/storage_service.dart';
import '../../features/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_detail_page.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({Key? key}) : super(key: key);

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isMenWardrobe = true; // Toggle for men/women wardrobe
  final ImagePicker _picker = ImagePicker();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final LocalStorageService _localStorageService = LocalStorageService();
  final WeatherService _weatherService = WeatherService(
    apiKey: '4c703f15e3f9220de836884137342d5d',
  );

  // State for uploaded clothing items
  List<LocalClothingItem> _uploadedItems = [];
  bool _isLoading = false;
  Map<String, List<LocalClothingItem>> _itemsByCategory = {};
  WeatherData? _weather;
  bool _weatherLoading = false;
  String _weatherCity = 'Islamabad';
  bool _forceDemoWeather = true; // hardcode demo weather when true

  // Demo weather data for different cities
  final Map<String, Map<String, dynamic>> _demoWeatherData = {
    'Islamabad': {
      'tempC': 22.0,
      'feelsLike': 23.0,
      'humidity': 55.0,
      'windSpeed': 8.0,
      'description': 'Clear',
      'icon': '01d',
    },
    'Karachi': {
      'tempC': 28.0,
      'feelsLike': 30.0,
      'humidity': 70.0,
      'windSpeed': 12.0,
      'description': 'Partly Cloudy',
      'icon': '02d',
    },
    'Lahore': {
      'tempC': 25.0,
      'feelsLike': 26.0,
      'humidity': 60.0,
      'windSpeed': 10.0,
      'description': 'Sunny',
      'icon': '01d',
    },
    'Rawalpindi': {
      'tempC': 21.0,
      'feelsLike': 22.0,
      'humidity': 50.0,
      'windSpeed': 7.0,
      'description': 'Clear',
      'icon': '01d',
    },
    'Peshawar': {
      'tempC': 24.0,
      'feelsLike': 25.0,
      'humidity': 65.0,
      'windSpeed': 9.0,
      'description': 'Cloudy',
      'icon': '04d',
    },
    'Quetta': {
      'tempC': 18.0,
      'feelsLike': 17.0,
      'humidity': 45.0,
      'windSpeed': 6.0,
      'description': 'Clear',
      'icon': '01d',
    },
  };

  // Getter to return appropriate clothing categories based on toggle
  List<ClothingCategory> get currentClothingCategories {
    return _isMenWardrobe ? menClothingCategories : womenClothingCategories;
  }

  // Men's clothing categories
  final List<ClothingCategory> menClothingCategories = [
    ClothingCategory(
      name: 'Trousers',
      icon: '👖',
      items: [
        ClothingItem(
          id: '1',
          name: 'Trousers',
          category: 'Trousers',
          imageUrl: 'assets/images/placeholder_trousers.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'T-Shirt',
      icon: '👕',
      items: [
        ClothingItem(
          id: '2',
          name: 'T-Shirt',
          category: 'T-Shirt',
          imageUrl: 'assets/images/placeholder_tshirt.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Sweater',
      icon: '🧥',
      items: [
        ClothingItem(
          id: '3',
          name: 'Sweater',
          category: 'Sweater',
          imageUrl: 'assets/images/placeholder_sweater.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Shorts',
      icon: '🩳',
      items: [
        ClothingItem(
          id: '4',
          name: 'Shorts',
          category: 'Shorts',
          imageUrl: 'assets/images/placeholder_shorts.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Shirt',
      icon: '👔',
      items: [
        ClothingItem(
          id: '5',
          name: 'Shirt',
          category: 'Shirt',
          imageUrl: 'assets/images/placeholder_shirt.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Pants',
      icon: '👖',
      items: [
        ClothingItem(
          id: '6',
          name: 'Pants',
          category: 'Pants',
          imageUrl: 'assets/images/placeholder_pants.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Kurta',
      icon: '👘',
      items: [
        ClothingItem(
          id: '7',
          name: 'Kurta',
          category: 'Kurta',
          imageUrl: 'assets/images/placeholder_kurta.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Jeans',
      icon: '👖',
      items: [
        ClothingItem(
          id: '8',
          name: 'Jeans',
          category: 'Jeans',
          imageUrl: 'assets/images/placeholder_jeans.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Jackets',
      icon: '🧥',
      items: [
        ClothingItem(
          id: '9',
          name: 'Jackets',
          category: 'Jackets',
          imageUrl: 'assets/images/placeholder_jacket.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Hoodie',
      icon: '👕',
      items: [
        ClothingItem(
          id: '10',
          name: 'Hoodie',
          category: 'Hoodie',
          imageUrl: 'assets/images/placeholder_hoodie.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Cotton Pants',
      icon: '👖',
      items: [
        ClothingItem(
          id: '11',
          name: 'Cotton Pants',
          category: 'Cotton Pants',
          imageUrl: 'assets/images/placeholder_cotton_pants.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Coat',
      icon: '🧥',
      items: [
        ClothingItem(
          id: '12',
          name: 'Coat',
          category: 'Coat',
          imageUrl: 'assets/images/placeholder_coat.png',
        ),
      ],
    ),
  ];

  // Women's clothing categories
  final List<ClothingCategory> womenClothingCategories = [
    ClothingCategory(
      name: 'Capris',
      icon: '🩳',
      items: [
        ClothingItem(
          id: '1',
          name: 'Capris',
          category: 'Capris',
          imageUrl: 'assets/images/placeholder_capris.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Coat',
      icon: '🧥',
      items: [
        ClothingItem(
          id: '2',
          name: 'Coat',
          category: 'Coat',
          imageUrl: 'assets/images/placeholder_coat.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Dupatta',
      icon: '🧣',
      items: [
        ClothingItem(
          id: '3',
          name: 'Dupatta',
          category: 'Dupatta',
          imageUrl: 'assets/images/placeholder_dupatta.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Jacket',
      icon: '🧥',
      items: [
        ClothingItem(
          id: '4',
          name: 'Jacket',
          category: 'Jacket',
          imageUrl: 'assets/images/placeholder_jacket.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Jeans',
      icon: '👖',
      items: [
        ClothingItem(
          id: '5',
          name: 'Jeans',
          category: 'Jeans',
          imageUrl: 'assets/images/placeholder_jeans.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Kurtas',
      icon: '👘',
      items: [
        ClothingItem(
          id: '6',
          name: 'Kurtas',
          category: 'Kurtas',
          imageUrl: 'assets/images/placeholder_kurtas.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Leggings',
      icon: '🩱',
      items: [
        ClothingItem(
          id: '7',
          name: 'Leggings',
          category: 'Leggings',
          imageUrl: 'assets/images/placeholder_leggings.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Puffer Jacket',
      icon: '🧥',
      items: [
        ClothingItem(
          id: '8',
          name: 'Puffer Jacket',
          category: 'Puffer Jacket',
          imageUrl: 'assets/images/placeholder_puffer_jacket.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Shirts',
      icon: '👔',
      items: [
        ClothingItem(
          id: '9',
          name: 'Shirts',
          category: 'Shirts',
          imageUrl: 'assets/images/placeholder_shirts.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Tops',
      icon: '👕',
      items: [
        ClothingItem(
          id: '10',
          name: 'Tops',
          category: 'Tops',
          imageUrl: 'assets/images/placeholder_tops.png',
        ),
      ],
    ),
    ClothingCategory(
      name: 'Trousers',
      icon: '👖',
      items: [
        ClothingItem(
          id: '11',
          name: 'Trousers',
          category: 'Trousers',
          imageUrl: 'assets/images/placeholder_trousers.png',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
    _loadClothingItems();
    if (_forceDemoWeather) {
      // Load demo weather for current city
      _loadDemoWeather();
    } else {
      _loadWeather();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Load clothing items from local database
  Future<void> _loadClothingItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final gender = _isMenWardrobe ? 'men' : 'women';
      final items = await _databaseHelper.getClothingItemsByGender(gender);
      setState(() {
        _uploadedItems = items;
        _groupItemsByCategory();
      });
    } catch (e) {
      print('Error loading clothing items: $e');
      _showSnackBar('Error loading clothing items: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Group items by category
  void _groupItemsByCategory() {
    _itemsByCategory.clear();
    for (final item in _uploadedItems) {
      final category = item.category.toLowerCase();
      if (!_itemsByCategory.containsKey(category)) {
        _itemsByCategory[category] = [];
      }
      _itemsByCategory[category]!.add(item);
    }
  }

  void _loadDemoWeather() {
    setState(() {
      _weatherLoading = true;
    });

    // Get weather data for current city or default to Islamabad
    final cityData =
        _demoWeatherData[_weatherCity] ?? _demoWeatherData['Islamabad']!;

    setState(() {
      _weather = WeatherData(
        city: _weatherCity,
        tempC: cityData['tempC'],
        feelsLike: cityData['feelsLike'] ?? cityData['tempC'],
        humidity: cityData['humidity'] ?? 60.0,
        windSpeed: cityData['windSpeed'] ?? 10.0,
        description: cityData['description'],
        icon: cityData['icon'],
      );
      _weatherLoading = false;
    });
  }

  Future<void> _loadWeather() async {
    setState(() {
      _weatherLoading = true;
    });
    try {
      final w = await _weatherService.fetchByCity(_weatherCity);
      setState(() {
        _weather = w;
      });
    } catch (e) {
      _showSnackBar('Weather error: $e');
    } finally {
      setState(() {
        _weatherLoading = false;
      });
    }
  }

  // Get items for a specific category
  List<LocalClothingItem> _getItemsForCategory(String categoryName) {
    return _itemsByCategory[categoryName.toLowerCase()] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(child: _buildWardrobeGrid()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title and Logout Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Wardrobe',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3436),
                ),
              ),
              GestureDetector(
                onTap: _showLogoutDialog,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFFE9ECEF),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.logout,
                    color: const Color(0xFF636E72),
                    size: 20.w,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (_weatherLoading)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: const LinearGradient(
                  colors: [Color(0xFF74B9FF), Color(0xFFA29BFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Fetching weather...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else if (_weather != null)
            GestureDetector(
              onTap: _promptChangeCity,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFE84393)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.network(
                      _weatherService.iconUrl(_weather!.icon),
                      width: 52.w,
                      height: 52.w,
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _weather!.city,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.edit_location_alt,
                                size: 18.w,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _weather!.description,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_weather!.tempC.toStringAsFixed(0)}°C',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 12.h),
          // Cupertino-style Gender Toggle
          Row(
            children: [
              Text(
                'Men',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: _isMenWardrobe
                      ? const Color(0xFF6C5CE7)
                      : const Color(0xFF636E72),
                ),
              ),
              SizedBox(width: 16.w),
              CupertinoSwitch(
                value:
                    !_isMenWardrobe, // Inverted because we want Men = false, Women = true
                onChanged: (bool value) {
                  setState(() {
                    _isMenWardrobe = !value;
                  });
                  _loadClothingItems(); // Refresh items when switching gender
                },
                activeColor: const Color(0xFFE84393), // Pink for Women
                trackColor: const Color(
                  0xFF6C5CE7,
                ).withOpacity(0.3), // Purple for Men
              ),
              SizedBox(width: 16.w),
              Text(
                'Women',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: !_isMenWardrobe
                      ? const Color(0xFFE84393)
                      : const Color(0xFF636E72),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWardrobeGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 0.75, // Increased length by reducing aspect ratio
        ),
        itemCount: currentClothingCategories.length,
        itemBuilder: (context, index) {
          final category = currentClothingCategories[index];
          return _buildClothingCard(category, index);
        },
      ),
    );
  }

  Widget _buildClothingCard(ClothingCategory category, int index) {
    final categoryItems = _getItemsForCategory(category.name);
    final hasItems = categoryItems.isNotEmpty;
    final color = _getCategoryColor(category.name);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () => _onCategoryTap(category),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: hasItems
                            ? Colors.transparent
                            : color.withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          topRight: Radius.circular(16.r),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              category.icon,
                              style: TextStyle(fontSize: 56.sp, color: color),
                            ),
                          ),
                          // Add button
                          Positioned(
                            top: 12.h,
                            right: 12.w,
                            child: GestureDetector(
                              onTap: () => _onAddButtonTap(category),
                              child: Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: color,
                                  size: 16.w,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D3436),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (hasItems)
                            Text(
                              '${categoryItems.length} item${categoryItems.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF7F8C8D),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String categoryName) {
    final colors = {
      // Men's clothing colors
      'Trousers': const Color(0xFF6C5CE7),
      'T-Shirt': const Color(0xFF00B894),
      'Sweater': const Color(0xFFE17055),
      'Shorts': const Color(0xFF00CEC9),
      'Shirt': const Color(0xFF74B9FF),
      'Pants': const Color(0xFF6C5CE7),
      'Kurta': const Color(0xFFA29BFE),
      'Jeans': const Color(0xFF2D3436),
      'Jackets': const Color(0xFF636E72),
      'Hoodie': const Color(0xFF00B894),
      'Cotton Pants': const Color(0xFF6C5CE7),
      'Coat': const Color(0xFF636E72),

      // Women's clothing colors
      'Capris': const Color(0xFF00CEC9),
      'Dupatta': const Color(0xFFE84393),
      'Jacket': const Color(0xFF636E72),
      'Kurtas': const Color(0xFFA29BFE),
      'Leggings': const Color(0xFFE84393),
      'Puffer Jacket': const Color(0xFF636E72),
      'Shirts': const Color(0xFF74B9FF),
      'Tops': const Color(0xFF00B894),
    };
    return colors[categoryName] ?? const Color(0xFF6C5CE7);
  }

  void _onCategoryTap(ClothingCategory category) {
    // Navigate to category detail page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailPage(
          categoryName: category.name,
          gender: _isMenWardrobe ? 'men' : 'women',
          categoryIcon: category.icon,
        ),
      ),
    );
  }

  void _onAddButtonTap(ClothingCategory category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9ECEF),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Add ${category.name}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Choose how you want to add your ${category.name.toLowerCase()}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF636E72),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildUploadOption(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        color: const Color(0xFF74B9FF),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery, category);
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildUploadOption(
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        color: const Color(0xFF00B894),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera, category);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _promptChangeCity() async {
    final controller = TextEditingController(text: _weatherCity);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change city'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter city name'),
            textInputAction: TextInputAction.done,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    ).then((value) async {
      if (value is String && value.isNotEmpty) {
        setState(() {
          _weatherCity = value;
        });
        if (_forceDemoWeather) {
          _loadDemoWeather();
        } else {
          await _loadWeather();
        }
      }
    });
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32.w),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, ClothingCategory category) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // Show loading message
        _showSnackBar('Uploading ${category.name}...');

        try {
          // Save image to local storage
          final String imagePath = await _localStorageService.saveImage(
            File(image.path),
            category.name,
            _isMenWardrobe ? 'men' : 'women',
          );

          // Create local clothing item
          final LocalClothingItem clothingItem = LocalClothingItem(
            name: category.name,
            category: category.name.toLowerCase(),
            gender: _isMenWardrobe ? 'men' : 'women',
            imagePath: imagePath,
            description: 'Uploaded from wardrobe',
            createdAt: DateTime.now(),
          );

          // Save to database
          await _databaseHelper.insertClothingItem(clothingItem);

          // Show success message
          _showSnackBar('${category.name} uploaded successfully!');

          print('Uploaded clothing item: ${clothingItem.name}');
          print('Category: ${category.name}');
          print('Gender: ${_isMenWardrobe ? 'Men' : 'Women'}');
          print('Image Path: ${clothingItem.imagePath}');

          // Refresh the wardrobe grid to show the new item
          await _loadClothingItems();
        } catch (e) {
          _showSnackBar('Error saving image: ${e.toString()}');
          print('Error saving image: $e');
        }
      }
    } catch (e) {
      // Handle any errors that occur during image picking
      _showSnackBar('Error picking image: ${e.toString()}');
      print('Error picking image: $e');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE84393).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Icon(
                      Icons.logout,
                      color: const Color(0xFFE84393),
                      size: 30.w,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Title
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3436),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Message
                  Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF636E72),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(0xFFE9ECEF),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF636E72),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            _performLogout();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE84393), Color(0xFF6C5CE7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _performLogout() async {
    try {
      // Clear local storage
      await StorageService.clearAll();

      // Clear local database data
      try {
        await _databaseHelper.clearAllData();
      } catch (dbError) {
        print('Database clear error (non-critical): $dbError');
        // Continue with logout even if database clear fails
      }

      // Trigger logout in auth bloc
      if (mounted) {
        context.read<AuthBloc>().add(AuthLogoutRequested());
      }

      _showSnackBar('Logged out successfully');
    } catch (e) {
      _showSnackBar('Error during logout: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2D3436),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}
