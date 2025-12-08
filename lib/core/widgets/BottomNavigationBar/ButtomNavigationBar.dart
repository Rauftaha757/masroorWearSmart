import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../features/wardrobe/wardrobe_page.dart';
import '../../../features/recommendation/recommendation_page.dart';
import '../../../features/virtual_try_on/virtual_try_on_page.dart';

// Screen Utilities Class
class ScreenUtil {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;
  }

  // Get responsive width
  static double w(double width) => blockSizeHorizontal * width;

  // Get responsive height
  static double h(double height) => blockSizeVertical * height;

  // Get responsive font size
  static double sp(double fontSize) => blockSizeHorizontal * fontSize * 0.4;

  // Get safe responsive width
  static double sw(double width) => safeBlockHorizontal * width;

  // Get safe responsive height
  static double sh(double height) => safeBlockVertical * height;
}

class CarouselNavUploadScreen extends StatefulWidget {
  @override
  _CarouselNavUploadScreenState createState() =>
      _CarouselNavUploadScreenState();
}

class _CarouselNavUploadScreenState extends State<CarouselNavUploadScreen>
    with TickerProviderStateMixin {
  PageController _pageController = PageController(initialPage: 0);
  int currentPage = 0; // 0 = nav bar, 1 = upload button
  int selectedNavIndex = 0;
  bool _showUploadOptions = false;

  final List<NavItem> navItems = [
    NavItem(Icons.home_outlined, 'Home'),
    NavItem(Icons.checkroom_outlined, 'Wardrobe'),
    NavItem(Icons.auto_awesome_outlined, 'Recommendations'),
    NavItem(Icons.folder_outlined, 'Files'),
    NavItem(Icons.add_circle_outline, 'Add'),
  ];

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context); // Initialize screen utilities

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: selectedNavIndex == 1
          ? const WardrobePage()
          : selectedNavIndex == 2
              ? const RecommendationPage()
              : Padding(
                  padding: EdgeInsets.all(ScreenUtil.w(5)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: ScreenUtil.h(5)),
                      Text(
                        currentPage == 0 ? 'Navigation Mode' : 'Upload Mode',
                        style: TextStyle(
                          fontSize: ScreenUtil.sp(28),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: ScreenUtil.h(2)),
                      Text(
                        currentPage == 0
                            ? 'Slide up to switch to upload button!'
                            : 'Slide down to switch back to navigation!',
                        style: TextStyle(
                          fontSize: ScreenUtil.sp(16),
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: ScreenUtil.h(5)),
                      Container(
                        width: double.infinity,
                        height: ScreenUtil.h(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(ScreenUtil.w(4)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: ScreenUtil.w(5),
                              spreadRadius: 0,
                              offset: Offset(0, ScreenUtil.h(0.5)),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                currentPage == 0
                                    ? navItems[selectedNavIndex].icon
                                    : Icons.cloud_upload,
                                size: ScreenUtil.w(12),
                                color: Colors.black54,
                              ),
                              SizedBox(height: ScreenUtil.h(1.5)),
                              Text(
                                currentPage == 0
                                    ? navItems[selectedNavIndex].label
                                    : 'Upload Files',
                                style: TextStyle(
                                  fontSize: ScreenUtil.sp(18),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Add Recommendation Button for Home page
                      if (selectedNavIndex == 0) ...[
                        SizedBox(height: ScreenUtil.h(3)),
                        _buildRecommendationButton(),
                        SizedBox(height: ScreenUtil.h(2)),
                        _buildVirtualTryOnButton(),
                      ],
                    ],
                  ),
                ),
      bottomNavigationBar: Container(
        height: ScreenUtil.h(9),
        margin: EdgeInsets.all(ScreenUtil.w(5)),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(ScreenUtil.w(8.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: ScreenUtil.w(6),
              spreadRadius: 0,
              offset: Offset(0, ScreenUtil.h(1.2)),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: ScreenUtil.w(3.5),
              spreadRadius: 0,
              offset: Offset(0, ScreenUtil.h(0.6)),
            ),
          ],
        ),
        child: _showUploadOptions
            ? _buildUploadOptionsView()
            : PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                scrollDirection: Axis.vertical,
                children: [
                  // Navigation Bar Page
                  _buildNavigationBar(),
                  // Upload Button Page
                  _buildUploadButton(),
                ],
              ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: navItems.asMap().entries.map((entry) {
        int index = entry.key;
        NavItem item = entry.value;
        bool isSelected = index == selectedNavIndex;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedNavIndex = index;
            });
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(ScreenUtil.w(3)),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.15)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Icon(
                item.icon,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.6),
                size: ScreenUtil.w(6),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUploadButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _showUploadOptions = true;
        });
      },
      borderRadius: BorderRadius.circular(ScreenUtil.w(8.5)),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(ScreenUtil.w(2)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                color: Colors.white,
                size: ScreenUtil.w(7),
              ),
            ),
            SizedBox(width: ScreenUtil.w(3)),
            Text(
              'Upload Files',
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil.sp(12),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: ScreenUtil.w(2)),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.7),
              size: ScreenUtil.w(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOptionsView() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil.w(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upload Collection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ScreenUtil.sp(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showUploadOptions = false;
                    });
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.7),
                    size: ScreenUtil.w(6),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil.h(2.5)),

            // Glass effect options
            Row(
              children: [
                Expanded(
                  child: _buildGlassOption(
                    icon: Icons.dry_cleaning_outlined, // Shirt icon
                    label: 'Shirt',
                    onTap: () => _selectCategory('Shirt'),
                  ),
                ),
                SizedBox(width: ScreenUtil.w(3.5)),
                Expanded(
                  child: _buildGlassOption(
                    icon: Icons.checkroom_outlined, // Pant icon
                    label: 'Pant',
                    onTap: () => _selectCategory('Pant'),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil.h(1.8)),
            Row(
              children: [
                Expanded(
                  child: _buildGlassOption(
                    icon: Icons.face_retouching_natural, // Shoes icon
                    label: 'Shoes',
                    onTap: () => _selectCategory('Shoes'),
                  ),
                ),
                SizedBox(width: ScreenUtil.w(3.5)),
                Expanded(
                  child: _buildGlassOption(
                    icon: Icons.shopping_bag_outlined, // Accessories icon
                    label: 'Accessories',
                    onTap: () => _selectCategory('Accessories'),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtil.h(1.8)),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ScreenUtil.w(3.5)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: ScreenUtil.h(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ScreenUtil.w(3.5)),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: ScreenUtil.w(7.5)),
                SizedBox(height: ScreenUtil.h(1)),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: ScreenUtil.sp(12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectCategory(String category) {
    setState(() {
      _showUploadOptions = false;
    });

    // Show bottom sheet for image upload
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: ScreenUtil.h(40),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(ScreenUtil.w(5)),
              topRight: Radius.circular(ScreenUtil.w(5)),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(ScreenUtil.w(5)),
            child: Column(
              children: [
                Text(
                  'Upload $category Images',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ScreenUtil.sp(12),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ScreenUtil.h(2.5)),
                Row(
                  children: [
                    Expanded(
                      child: _buildUploadOption(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        onTap: () {
                          Navigator.pop(context);
                          _showSnackBar('$category: Gallery selected');
                        },
                      ),
                    ),
                    SizedBox(width: ScreenUtil.w(3.5)),
                    Expanded(
                      child: _buildUploadOption(
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        onTap: () {
                          Navigator.pop(context);
                          _showSnackBar('$category: Camera selected');
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

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ScreenUtil.w(3.5)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: ScreenUtil.h(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ScreenUtil.w(3.5)),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: ScreenUtil.w(7)),
                SizedBox(height: ScreenUtil.h(1)),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: ScreenUtil.sp(12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScreenUtil.w(3)),
        ),
      ),
    );
  }

  Widget _buildRecommendationButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenUtil.w(4)),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(ScreenUtil.w(3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: ScreenUtil.w(4),
            offset: Offset(0, ScreenUtil.h(0.5)),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RecommendationPage(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(ScreenUtil.w(3)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: ScreenUtil.w(6),
            ),
            SizedBox(width: ScreenUtil.w(2)),
            Text(
              'Get Outfit Recommendations',
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil.sp(16),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: ScreenUtil.w(2)),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: ScreenUtil.w(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVirtualTryOnButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenUtil.w(4)),
      decoration: BoxDecoration(
        color: const Color(0xFF74B9FF),
        borderRadius: BorderRadius.circular(ScreenUtil.w(3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF74B9FF).withOpacity(0.3),
            blurRadius: ScreenUtil.w(4),
            offset: Offset(0, ScreenUtil.h(0.5)),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VirtualTryOnPage(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(ScreenUtil.w(3)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checkroom,
              color: Colors.white,
              size: ScreenUtil.w(6),
            ),
            SizedBox(width: ScreenUtil.w(2)),
            Text(
              'Virtual Try On',
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil.sp(16),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: ScreenUtil.w(2)),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: ScreenUtil.w(4),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class NavItem {
  final IconData icon;
  final String label;

  NavItem(this.icon, this.label);
}

// Alternative version with more upload options
class AdvancedCarouselNav extends StatefulWidget {
  @override
  _AdvancedCarouselNavState createState() => _AdvancedCarouselNavState();
}

class _AdvancedCarouselNavState extends State<AdvancedCarouselNav> {
  PageController _pageController = PageController(initialPage: 0);
  int currentPage = 0;
  int selectedNavIndex = 0;

  final List<CarouselPage> pages = [
    CarouselPage(
      type: CarouselPageType.navigation,
      title: 'Navigation',
      icon: Icons.apps,
    ),
    CarouselPage(
      type: CarouselPageType.upload,
      title: 'Upload Files',
      icon: Icons.cloud_upload,
    ),
    CarouselPage(
      type: CarouselPageType.settings,
      title: 'Quick Settings',
      icon: Icons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  pages[currentPage].title,
                  style: TextStyle(
                    fontSize: ScreenUtil.sp(24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ScreenUtil.h(2)),
                Text(
                  'Swipe up/down to switch modes',
                  style: TextStyle(fontSize: ScreenUtil.sp(16)),
                ),
              ],
            ),
          ),

          // Multi-page carousel
          Positioned(
            bottom: ScreenUtil.h(4),
            left: ScreenUtil.w(5),
            right: ScreenUtil.w(5),
            child: GestureDetector(
              onPanUpdate: (details) {
                if (details.delta.dy < -10 && currentPage < pages.length - 1) {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else if (details.delta.dy > 10 && currentPage > 0) {
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Container(
                height: ScreenUtil.h(9),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(ScreenUtil.w(8.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: ScreenUtil.w(6),
                      spreadRadius: 0,
                      offset: Offset(0, ScreenUtil.h(1.2)),
                    ),
                  ],
                ),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  scrollDirection: Axis.vertical,
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(pages[index]);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(CarouselPage page) {
    switch (page.type) {
      case CarouselPageType.navigation:
        return _buildNavigationContent();
      case CarouselPageType.upload:
        return _buildUploadContent();
      case CarouselPageType.settings:
        return _buildSettingsContent();
    }
  }

  Widget _buildNavigationContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNavIcon(Icons.home, 0),
        _buildNavIcon(Icons.search, 1),
        _buildNavIcon(Icons.favorite, 2),
        _buildNavIcon(Icons.person, 3),
        _buildNavIcon(Icons.menu, 4),
      ],
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = selectedNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedNavIndex = index),
      child: Container(
        padding: EdgeInsets.all(ScreenUtil.w(2.5)),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
          size: ScreenUtil.w(5.5),
        ),
      ),
    );
  }

  Widget _buildUploadContent() {
    return InkWell(
      onTap: () => _showSnackBar('Upload tapped'),
      borderRadius: BorderRadius.circular(ScreenUtil.w(8.5)),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload,
              color: Colors.white,
              size: ScreenUtil.w(6),
            ),
            SizedBox(width: ScreenUtil.w(3)),
            Text(
              'Upload Files',
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil.sp(16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContent() {
    return InkWell(
      onTap: () => _showSnackBar('Settings tapped'),
      borderRadius: BorderRadius.circular(ScreenUtil.w(8.5)),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, color: Colors.white, size: ScreenUtil.w(6)),
            SizedBox(width: ScreenUtil.w(3)),
            Text(
              'Quick Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenUtil.sp(16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

enum CarouselPageType { navigation, upload, settings }

class CarouselPage {
  final CarouselPageType type;
  final String title;
  final IconData icon;

  CarouselPage({required this.type, required this.title, required this.icon});
}
