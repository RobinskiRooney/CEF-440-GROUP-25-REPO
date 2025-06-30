// lib/screens/home_page.dart
import 'package:autofix_car/pages/dashboard_light_scanning_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for SystemChrome, though not directly used in HomePage's build method, it's good practice for screens
import 'package:google_fonts/google_fonts.dart'; // For Inter font, if specific styles within HomePage use it

import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
// import '../widgets/bottom_nav_bar.dart';
import '../widgets/camera_overlay_scanner.dart';
import '../pages/engine_diagnosis_page.dart';
import '../pages/profile_page.dart';
import 'help_and_support_page.dart'; // Ensure this is imported if used in bottom nav or elsewhere
import 'package:autofix_car/services/user_service.dart';
import 'package:autofix_car/models/user_profile.dart';
import 'package:autofix_car/services/notification_service.dart';
import 'package:autofix_car/models/notification_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _error;
  List<NotificationItem> _notifications = [];
  bool _isLoadingNotifications = true;
  String? _notificationError;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchNotifications();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profile = await UserService.getUserProfile();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoadingNotifications = true;
      _notificationError = null;
    });
    try {
      final notifications = await NotificationService.getMyNotifications();
      setState(() {
        _notifications = notifications;
        _isLoadingNotifications = false;
      });
    } catch (e) {
      setState(() {
        _notificationError = e.toString();
        _isLoadingNotifications = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildVehicleCategories(),
            _buildDiagnosisCards(context),
            _buildNotificationsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.only(
          top: 60.0,
          left: 24.0,
          right: 24.0,
          bottom: 20.0,
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Container(
        padding: const EdgeInsets.only(
          top: 60.0,
          left: 24.0,
          right: 24.0,
          bottom: 20.0,
        ),
        child: Center(
          child: Text('Error: $_error', style: TextStyle(color: Colors.red)),
        ),
      );
    }
    final user = _userProfile;
    return Container(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 24.0,
        right: 24.0,
        bottom: 20.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.lightBlueGradientStart, AppColors.blueGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome!',
                    style: AppStyles.headline1.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                  (user?.name ?? '').isNotEmpty
                  ? user!.name!
                  : (user?.email ?? ''),
                  style: AppStyles.bodyText.copyWith(color: Colors.white70),
                  ),
                  if ((user?.carModel ?? '').isNotEmpty)
                  Text(
                  'Car: ${user!.carModel}',
                  style: AppStyles.bodyText.copyWith(color: Colors.white70),
                  ),
                  if ((user?.userLocation ?? '').isNotEmpty)
                  Text(
                  'Location: ${user!.userLocation}',
                  style: AppStyles.bodyText.copyWith(color: Colors.white70),
                  ),
                  if ((user?.mobileContact ?? '').isNotEmpty)
                  Text(
                  'Contact: ${user!.mobileContact}',
                  style: AppStyles.bodyText.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      user?.imageUrl != null && user!.imageUrl!.isNotEmpty
                      ? NetworkImage(user.imageUrl!) as ImageProvider
                      : const AssetImage('assets/images/profile_pic.png'),
                  onBackgroundImageError: (exception, stackTrace) {
                    print('Error loading profile picture: $exception');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withOpacity(0.7),
                ),
                suffixIcon: Icon(
                  Icons.mic,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCategories() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Categories',
            style: AppStyles.headline2.copyWith(
              color: AppColors.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCategoryItem(Icons.motorcycle, 'Bike'),
              _buildCategoryItem(Icons.directions_car, 'Car'),
              _buildCategoryItem(Icons.directions_bus, 'Bus'),
              _buildCategoryItem(Icons.airport_shuttle, 'Van'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        // Add category selection logic here
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withOpacity(0.1),
                  AppColors.primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 32,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppStyles.bodyText.copyWith(
              color: AppColors.textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCards(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Diagnosis Tools',
            style: AppStyles.headline2.copyWith(
              color: AppColors.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildDiagnosisCard(
            context,
            'Engine Sound Diagnosis',
            'AI powered engine sound analysis',
            AppColors.lightBlueCard,
            Icons.graphic_eq,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EngineDiagnosisPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildDiagnosisCard(
            context,
            'Dashboard Light Scanning',
            'AI powered dashboard light analysis',
            AppColors.lightOrangeCard,
            Icons.lightbulb_outline,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardLightScanningPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.headline3.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: AppStyles.bodyText.copyWith(
                      color: AppColors.greyTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    if (_isLoadingNotifications) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_notificationError != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Error: $_notificationError',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    // Limit notifications to maximum 3
    final displayNotifications = _notifications.take(3).toList();
    final hasMoreNotifications = _notifications.length > 3;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Notifications',
                style: AppStyles.headline2.copyWith(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasMoreNotifications)
                GestureDetector(
                  onTap: () {
                    _showAllNotifications();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      'View All',
                      style: AppStyles.bodyText.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _notifications.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_none,
                        color: AppColors.greyTextColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'No notifications yet',
                        style: AppStyles.bodyText.copyWith(
                          color: AppColors.greyTextColor,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...displayNotifications.map((notification) {
                        return Row(
                          children: [
                            _buildNotificationCard(
                              notification.imageUrl ?? 'assets/images/d1.png',
                              notification.title,
                              notification.message,
                            ),
                            const SizedBox(width: 15),
                          ],
                        );
                      }).toList(),
                      if (hasMoreNotifications)
                        _buildMoreNotificationsCard(),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  void _showAllNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Notifications',
                    style: AppStyles.headline2.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            notification.imageUrl ?? 'assets/images/d1.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: AppColors.lightGrey,
                                child: const Icon(
                                  Icons.notifications,
                                  color: AppColors.greyTextColor,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.title,
                                style: AppStyles.headline3.copyWith(
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification.message,
                                style: AppStyles.bodyText.copyWith(
                                  color: AppColors.greyTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreNotificationsCard() {
    final remainingCount = _notifications.length - 3;
    return GestureDetector(
      onTap: _showAllNotifications,
      child: Container(
        width: 180,
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withOpacity(0.1),
              AppColors.primaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: Icon(
                Icons.add,
                size: 32,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '+$remainingCount More',
              style: AppStyles.headline3.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'View all notifications',
              style: AppStyles.bodyText.copyWith(
                color: AppColors.greyTextColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    String imagePath,
    String title,
    String description,
  ) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16.0),
            ),
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.1),
                    AppColors.primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading notification asset: $imagePath - $error');
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor.withOpacity(0.1),
                          AppColors.primaryColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.notifications_active,
                        color: AppColors.primaryColor,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.headline3.copyWith(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppStyles.bodyText.copyWith(
                    color: AppColors.greyTextColor,
                    fontSize: 12,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'New',
                    style: AppStyles.bodyText.copyWith(
                      color: AppColors.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
