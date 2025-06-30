// lib/pages/mechanics_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/mechanic.dart';
import '../services/mechanic_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../widgets/mechanic_card.dart';

class MechanicsPage extends StatefulWidget {
  const MechanicsPage({super.key});

  @override
  State<MechanicsPage> createState() => _MechanicsPageState();
}

class _MechanicsPageState extends State<MechanicsPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Mechanic> _mechanics = [];
  List<Mechanic> _filteredMechanics = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final List<String> _cameroonRegions = [
    'All Regions',
    'Adamawa',
    'Centre',
    'East',
    'Far North',
    'Littoral',
    'North',
    'North-West',
    'South',
    'South-West',
    'West',
  ];

  String? _selectedRegion;

  @override
  void initState() {
    super.initState();
    _selectedRegion = _cameroonRegions[0];
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadMechanics();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMechanics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      _mechanics = await MechanicService.getAllMechanics();
      _applyFilters();
      _animationController.forward();
    } catch (e) {
      debugPrint('Error loading mechanics: $e');
      setState(() {
        _errorMessage = 'Failed to load mechanics: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final String query = _searchController.text.toLowerCase();
    final String? region = _selectedRegion;

    setState(() {
      _filteredMechanics = _mechanics.where((mechanic) {
        final bool matchesSearch =
            mechanic.name.toLowerCase().contains(query) ||
            mechanic.address.toLowerCase().contains(query) ||
            mechanic.specialties.any((s) => s.toLowerCase().contains(query));

        final bool matchesRegion =
            region == null ||
            region == 'All Regions' ||
            (mechanic.address.toLowerCase().contains(region.toLowerCase()));

        return matchesSearch && matchesRegion;
      }).toList();
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanedPhoneNumber);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showSnackBar(
        'Could not launch phone dialer for $phoneNumber',
        isError: true,
      );
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber, String message) async {
    final cleanedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final String url =
        'https://wa.me/$cleanedPhoneNumber?text=${Uri.encodeComponent(message)}';
    final Uri launchUri = Uri.parse(url);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showSnackBar(
        'Could not launch WhatsApp. Make sure WhatsApp is installed.',
        isError: true,
      );
    }
  }

  Future<void> _openWebsite(String? websiteUrl) async {
    if (websiteUrl == null || websiteUrl.isEmpty) {
      _showSnackBar('No website available for this mechanic.', isError: true);
      return;
    }
    final Uri launchUri = Uri.parse(websiteUrl);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showSnackBar('Could not launch $websiteUrl', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _isLoading
                ? _buildLoadingWidget()
                : _errorMessage.isNotEmpty
                ? _buildErrorWidget()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        _buildSearchAndFilterSection(),
                        _buildMechanicsListSection(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () =>
                _showSnackBar('Notifications feature coming soon!'),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Find Mechanics',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor,
                ),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Finding mechanics near you...',
              style: AppStyles.bodyText1.copyWith(
                color: AppColors.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: AppStyles.headline3.copyWith(color: AppColors.textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              style: AppStyles.bodyText2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadMechanics,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search & Filter',
            style: AppStyles.headline3.copyWith(
              color: AppColors.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputFillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search mechanics, specialties, or location',
                hintStyle: AppStyles.bodyText2.copyWith(
                  color: Colors.grey[500],
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.search,
                    color: AppColors.primaryColor,
                    size: 22,
                  ),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[500]),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.mic,
                          color: Colors.grey[400],
                          size: 22,
                        ),
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (query) => _applyFilters(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.inputFillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedRegion,
              decoration: InputDecoration(
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.location_on,
                    color: AppColors.primaryColor,
                    size: 22,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              items: _cameroonRegions.map((String region) {
                return DropdownMenuItem<String>(
                  value: region,
                  child: Text(region, style: AppStyles.bodyText1),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRegion = newValue;
                  _applyFilters();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMechanicsListSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Mechanics',
                    style: AppStyles.headline3.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_filteredMechanics.length} mechanics found',
                    style: AppStyles.bodyText2.copyWith(
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_filteredMechanics.length}',
                  style: AppStyles.bodyText1.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _filteredMechanics.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: _loadMechanics,
                color: AppColors.primaryColor,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _filteredMechanics.length,
                  itemBuilder: (context, index) {
                    final mechanic = _filteredMechanics[index];
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      curve: Curves.easeOutBack,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: MechanicCard(
                        mechanic: mechanic,
                        onMessage: (mech) => _launchWhatsApp(
                          mech.phone,
                          'Hello ${mech.name}, I need assistance with my car from the AutoFix app.',
                        ),
                        onCall: (mech) => _makePhoneCall(mech.phone),
                        onShare: (mech) =>
                            _showSnackBar('Share feature coming soon!'),
                      ),
                    );
                  },
                ),
              ),
        const SizedBox(height: 100), // Extra space at bottom
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.search_off,
                size: 48,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _mechanics.isEmpty
                  ? 'No mechanics available'
                  : 'No mechanics found',
              style: AppStyles.headline3.copyWith(color: AppColors.textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _mechanics.isEmpty
                  ? 'We\'re working to add more mechanics to your area.'
                  : 'Try adjusting your search criteria or region filter.',
              style: AppStyles.bodyText2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedRegion = 'All Regions';
                });
                _applyFilters();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
