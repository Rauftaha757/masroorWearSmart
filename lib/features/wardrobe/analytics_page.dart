import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

class AnalyticsPage extends StatefulWidget {
  final String gender; // 'men' or 'women'

  const AnalyticsPage({Key? key, this.gender = 'men'}) : super(key: key);

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  // Hardcoded analytics data
  final List<CategoryData> _categoryData = [
    CategoryData(name: 'T-Shirts', count: 8, threshold: 10, icon: '👕'),
    CategoryData(name: 'Jeans', count: 5, threshold: 8, icon: '👖'),
    CategoryData(name: 'Shirts', count: 12, threshold: 10, icon: '👔'),
    CategoryData(name: 'Jackets', count: 3, threshold: 6, icon: '🧥'),
    CategoryData(name: 'Shoes', count: 6, threshold: 8, icon: '👟'),
    CategoryData(name: 'Pants', count: 7, threshold: 8, icon: '👖'),
    CategoryData(name: 'Sweaters', count: 4, threshold: 6, icon: '🧥'),
    CategoryData(name: 'Shorts', count: 9, threshold: 8, icon: '🩳'),
  ];

  final List<ColorData> _colorData = [
    ColorData(name: 'Black', count: 15, threshold: 20, color: Colors.black),
    ColorData(name: 'White', count: 12, threshold: 20, color: Colors.white),
    ColorData(name: 'Blue', count: 8, threshold: 15, color: Colors.blue),
    ColorData(name: 'Red', count: 5, threshold: 12, color: Colors.red),
    ColorData(name: 'Green', count: 3, threshold: 10, color: Colors.green),
    ColorData(name: 'Gray', count: 10, threshold: 15, color: Colors.grey),
    ColorData(name: 'Brown', count: 4, threshold: 10, color: Colors.brown),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3436)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Wardrobe Analytics',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3436),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            SizedBox(height: 20.h),
            _buildCategoryChart(),
            SizedBox(height: 20.h),
            _buildColorChart(),
            SizedBox(height: 20.h),
            _buildShoppingRecommendations(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final lowStockItems = _categoryData
        .where((item) => item.count < item.threshold)
        .length;
    final totalItems = _categoryData.fold<int>(
      0,
      (sum, item) => sum + item.count,
    );

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFFE84393)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wardrobe Overview',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Items',
                  totalItems.toString(),
                  Icons.checkroom,
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Low Stock',
                  lowStockItems.toString(),
                  Icons.warning_amber_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24.w),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChart() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clothing Categories',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3436),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 250.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 15,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8.r,
                    tooltipBgColor: const Color(0xFF6C5CE7),
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= _categoryData.length) {
                          return const Text('');
                        }
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            _categoryData[value.toInt()].icon,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xFF636E72),
                            ),
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF636E72),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE9ECEF),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: _categoryData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLow = item.count < item.threshold;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: item.count.toDouble(),
                        color: isLow
                            ? const Color(0xFFE84393)
                            : const Color(0xFF00B894),
                        width: 20.w,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4.r),
                          topRight: Radius.circular(4.r),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Low Stock', const Color(0xFFE84393)),
              SizedBox(width: 20.w),
              _buildLegendItem('Good Stock', const Color(0xFF00B894)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorChart() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color Distribution',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3436),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 200.h,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60.r,
                sections: _colorData.map((colorData) {
                  return PieChartSectionData(
                    value: colorData.count.toDouble(),
                    color: colorData.color,
                    title: '${colorData.count}',
                    radius: 50.r,
                    titleStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            children: _colorData.map((colorData) {
              final isLow = colorData.count < colorData.threshold;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: colorData.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isLow ? const Color(0xFFE84393) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        color: colorData.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${colorData.name}: ${colorData.count}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: isLow ? FontWeight.w600 : FontWeight.normal,
                        color: const Color(0xFF2D3436),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingRecommendations() {
    final lowStockItems = _categoryData
        .where((item) => item.count < item.threshold)
        .toList();
    final lowStockColors = _colorData
        .where((item) => item.count < item.threshold)
        .toList();

    if (lowStockItems.isEmpty && lowStockColors.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B894).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: const Color(0xFF00B894),
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Great! Your wardrobe is well-stocked!',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00B894),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildShoppingButtons(),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFE84393).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.shopping_cart,
                  color: const Color(0xFFE84393),
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Shopping Recommendations',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (lowStockItems.isNotEmpty) ...[
            Text(
              'Low Stock Categories:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF636E72),
              ),
            ),
            SizedBox(height: 12.h),
            ...lowStockItems.map((item) {
              final needed = item.threshold - item.count;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Text(item.icon, style: TextStyle(fontSize: 20.sp)),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF2D3436),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE84393).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Need $needed more',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE84393),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (lowStockColors.isNotEmpty) SizedBox(height: 16.h),
          ],
          if (lowStockColors.isNotEmpty) ...[
            Text(
              'Low Stock Colors:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF636E72),
              ),
            ),
            SizedBox(height: 12.h),
            ...lowStockColors.map((item) {
              final needed = item.threshold - item.count;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF2D3436),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE84393).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Need $needed more',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE84393),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          SizedBox(height: 20.h),
          _buildShoppingButtons(),
        ],
      ),
    );
  }

  Widget _buildShoppingButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 1,
          color: const Color(0xFFE9ECEF),
          margin: EdgeInsets.symmetric(vertical: 16.h),
        ),
        Text(
          'Shop Now',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3436),
          ),
        ),
        SizedBox(height: 12.h),
        // Outfitters Button
        GestureDetector(
          onTap: () => _launchShopUrl(
            'https://outfitters.com.pk/pages/shop-by-categories',
          ),
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.shopping_bag,
                    color: Colors.white,
                    size: 24.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shop at Outfitters',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Men\'s fashion & clothing',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18.w),
              ],
            ),
          ),
        ),
        // Khaadi Button
        GestureDetector(
          onTap: () => _launchShopUrl('https://www.khaadi.com/'),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE84393), Color(0xFFFF6B9D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE84393).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.store, color: Colors.white, size: 24.w),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shop at Khaadi',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Women\'s fashion & clothing',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18.w),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchShopUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $url'),
              backgroundColor: const Color(0xFFE84393),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: const Color(0xFFE84393),
          ),
        );
      }
    }
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16.w,
          height: 16.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF636E72)),
        ),
      ],
    );
  }
}

class CategoryData {
  final String name;
  final int count;
  final int threshold;
  final String icon;

  CategoryData({
    required this.name,
    required this.count,
    required this.threshold,
    required this.icon,
  });
}

class ColorData {
  final String name;
  final int count;
  final int threshold;
  final Color color;

  ColorData({
    required this.name,
    required this.count,
    required this.threshold,
    required this.color,
  });
}
