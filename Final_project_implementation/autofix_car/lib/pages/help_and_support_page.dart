// lib/screens/help_and_support_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'package:url_launcher/url_launcher.dart'; // For opening YouTube links

import '../models/faq_item.dart';
import '../services/faq_service.dart';

// No longer using app_colors.dart or app_styles.dart directly in this file
// as we are implementing a gradient AppBar and inline styles for better control.

class HelpAndSupportPage extends StatefulWidget {
  const HelpAndSupportPage({super.key});

  @override
  State<HelpAndSupportPage> createState() => _HelpAndSupportPageState();
}

class _HelpAndSupportPageState extends State<HelpAndSupportPage>
    with TickerProviderStateMixin {
  List<FAQItem> _faqs = [];
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Hardcoded tips
  final List<Map<String, String>> _tips = [
    {
      'title': 'Maintain Your Car Regularly',
      'description':
          'Regular maintenance prevents common problems and extends your vehicle\'s life. Follow manufacturer recommendations.',
    },
    {
      'title': 'Check Tire Pressure Weekly',
      'description':
          'Proper tire pressure is crucial for safety, fuel efficiency, and tire longevity. Check weekly and inflate to recommended PSI.',
    },
    {
      'title': 'Understand Dashboard Warning Lights',
      'description':
          'Familiarize yourself with warning lights. Ignoring them can lead to serious and costly repairs. Check your car manual.',
    },
    {
      'title': 'Keep Your Engine Clean',
      'description':
          'A clean engine runs more efficiently and makes it easier to spot leaks or other issues during inspections.',
    },
    {
      'title': 'Don\'t Ignore Strange Noises',
      'description':
          'Unusual sounds from your car often indicate an underlying problem. Address them promptly to avoid further damage.',
    },
  ];

  // Hardcoded YouTube video links (replace with actual relevant links)
  final List<Map<String, String>> _youtubeVideos = [
    {
      'title': 'Understanding Car Dashboard Lights',
      'thumbnail':
          'https://img.youtube.com/vi/Dq-O6gY2aAE/mqdefault.jpg', // Replace with actual thumbnail or embed logic
      'url':
          'https://www.youtube.com/watch?v=Dq-O6gY2aAE', // Replace with actual video ID
    },
    {
      'title': 'Basic Car Maintenance Tips',
      'thumbnail':
          'https://img.youtube.com/vi/W_J16iI8QcM/mqdefault.jpg', // Replace with actual thumbnail
      'url':
          'https://www.youtube.com/watch?v=W_J16iI8QcM', // Replace with actual video ID
    },
    {
      'title': 'How to Check Tire Pressure',
      'thumbnail':
          'https://img.youtube.com/vi/FmmH6fM4f_0/mqdefault.jpg', // Replace with actual thumbnail
      'url':
          'https://www.youtube.com/watch?v=FmmH6fM4f_0', // Replace with actual video ID
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadFAQs();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  Future<void> _loadFAQs() async {
    setState(() => _isLoading = true);
    try {
      _faqs = await FAQService.getAllFAQs();
      // Sort FAQs by their 'order' field if you want a specific display order
      _faqs.sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      debugPrint('Error loading FAQs: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load FAQs: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      toolbarHeight: 70,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E40AF), Color(0xFF3B82F6), Color(0xFF60A5FA)],
          ),
        ),
      ),
    
      title: const Column(
        children: [
          Text(
            'Help & Support',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Find Answers and Resources',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // Navigate to notification page
              // Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
              debugPrint('Navigate to Notification Page');
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildModernAppBar(context),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FAQs Section
          _buildSectionTitle('Frequently Asked Questions'),
          const SizedBox(height: 16),
          _isLoading
              ? _buildLoadingState()
              : _faqs.isEmpty
              ? _buildEmptyState('No FAQs available at the moment.')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _faqs.length,
                  itemBuilder: (context, index) {
                    final faq = _faqs[index];
                    return _buildFaqCard(
                      context,
                      question: faq.question,
                      answer: faq.answer,
                      isLast: index == _faqs.length - 1,
                    );
                  },
                ),

          const SizedBox(height: 30),

          // Tips Section
          _buildSectionTitle('Helpful Tips'),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tips.length,
            itemBuilder: (context, index) {
              final tip = _tips[index];
              return _buildTipCard(
                context,
                title: tip['title']!,
                description: tip['description']!,
                isLast: index == _tips.length - 1,
              );
            },
          ),

          const SizedBox(height: 30),

          // Video Tutorials Section
          _buildSectionTitle('Video Tutorials'),
          const SizedBox(height: 16),
          _youtubeVideos.isEmpty
              ? _buildEmptyState('No video tutorials available.')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _youtubeVideos.length,
                  itemBuilder: (context, index) {
                    final video = _youtubeVideos[index];
                    return _buildVideoCard(
                      context,
                      title: video['title']!,
                      thumbnailUrl: video['thumbnail']!,
                      videoUrl: video['url']!,
                      isLast: index == _youtubeVideos.length - 1,
                    );
                  },
                ),

          const SizedBox(height: 30),

          // Contact Support Section
          _buildSectionTitle('Contact Support'),
          const SizedBox(height: 16),
          _buildContactSupportCard(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E40AF), // Dark blue for section titles
      ),
    );
  }

  Widget _buildFaqCard(
    BuildContext context, {
    required String question,
    required String answer,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        // Use Theme to customize ExpansionTile's default icon color
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: const Color(0xFF3B82F6), // Blue icon when collapsed
          collapsedIconColor: Colors.grey[600], // Grey icon when expanded
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
          children: <Widget>[
            Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(
    BuildContext context, {
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(
    BuildContext context, {
    required String title,
    required String thumbnailUrl,
    required String videoUrl,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: () => _launchUrl(videoUrl),
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    thumbnailUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSupportCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need More Help?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E40AF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'If you can\'t find what you\'re looking for, feel free to reach out to our support team.',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchUrl('mailto:support@yourdomain.com'),
                  icon: const Icon(Icons.email, color: Color(0xFF3B82F6)),
                  label: const Text('Email Us'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                    side: const BorderSide(color: Color(0xFF3B82F6)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to a chat page or external chat link
                    debugPrint('Open Live Chat');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Live chat feature coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                  ),
                  label: const Text('Live Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF3B82F6)),
            SizedBox(height: 16),
            Text(
              'Loading FAQs...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
