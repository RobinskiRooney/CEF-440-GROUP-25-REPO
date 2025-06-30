import 'package:flutter/material.dart';
import 'package:autofix_car/models/mechanic.dart';
import 'package:autofix_car/constants/app_colors.dart';
import 'package:autofix_car/constants/app_styles.dart';

class MechanicCard extends StatefulWidget {
  final Mechanic mechanic;
  final Function(Mechanic) onMessage;
  final Function(Mechanic) onCall;
  final Function(Mechanic)? onShare;
  final VoidCallback? onTap;

  const MechanicCard({
    super.key,
    required this.mechanic,
    required this.onMessage,
    required this.onCall,
    this.onShare,
    this.onTap,
  });

  @override
  State<MechanicCard> createState() => _MechanicCardState();
}

class _MechanicCardState extends State<MechanicCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  Color get _verificationColor {
    switch (widget.mechanic.verificationStatus.toLowerCase()) {
      case 'verified':
        return AppColors.successColor;
      case 'pending':
        return Colors.orange;
      default:
        return AppColors.errorColor;
    }
  }

  IconData get _verificationIcon {
    switch (widget.mechanic.verificationStatus.toLowerCase()) {
      case 'verified':
        return Icons.verified;
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.error_outline;
    }
  }

  String get _distanceText {
    // You can calculate actual distance here if you have coordinates
    // For now, using a placeholder
    return "2.5 km away";
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _isPressed
                      ? Colors.black.withOpacity(0.15)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: _isPressed ? 8 : 12,
                  offset: Offset(0, _isPressed ? 2 : 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap ?? () => _showMechanicDetails(context),
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildRatingAndVerification(),
                      const SizedBox(height: 16),
                      _buildSpecialties(),
                      const SizedBox(height: 16),
                      _buildContactInfo(),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: widget.mechanic.name.isNotEmpty
                ? Text(
                    widget.mechanic.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const Icon(Icons.build, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.mechanic.name,
                      style: AppStyles.headline3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Available',
                      style: AppStyles.smallText.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.secondaryTextColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.mechanic.address,
                      style: AppStyles.bodyText2.copyWith(
                        color: AppColors.secondaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _distanceText,
                style: AppStyles.smallText.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingAndVerification() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                widget.mechanic.rating.toStringAsFixed(1),
                style: AppStyles.bodyText2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _verificationColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_verificationIcon, color: _verificationColor, size: 16),
              const SizedBox(width: 4),
              Text(
                widget.mechanic.verificationStatus,
                style: AppStyles.bodyText2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _verificationColor,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (widget.mechanic.phone.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone, size: 14, color: Colors.green[600]),
                const SizedBox(width: 4),
                Text(
                  'Available',
                  style: AppStyles.smallText.copyWith(
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSpecialties() {
    if (widget.mechanic.specialties.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specialties',
          style: AppStyles.labelText.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.mechanic.specialties.take(4).map((specialty) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.1),
                    AppColors.primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Text(
                specialty,
                style: AppStyles.bodyText2.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
        if (widget.mechanic.specialties.length > 4)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '+${widget.mechanic.specialties.length - 4} more',
              style: AppStyles.smallText.copyWith(
                color: AppColors.secondaryTextColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.secondaryTextColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tap to view full details and contact information',
              style: AppStyles.smallText.copyWith(
                color: AppColors.secondaryTextColor,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: AppColors.secondaryTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.phone,
            label: 'Call',
            color: AppColors.primaryColor,
            onPressed: () => widget.onCall(widget.mechanic),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: 'Message',
            color: Colors.green,
            onPressed: () => widget.onMessage(widget.mechanic),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            color: AppColors.secondaryTextColor,
            onPressed: widget.onShare != null
                ? () => widget.onShare!(widget.mechanic)
                : null,
            tooltip: 'Share',
          ),
        ),
      ],
    );
  }

  void _showMechanicDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: _buildDetailedView(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildDetailSection('Contact Information', [
          if (widget.mechanic.phone.isNotEmpty)
            _buildDetailItem(Icons.phone, 'Phone', widget.mechanic.phone),
          if (widget.mechanic.email != null &&
              widget.mechanic.email!.isNotEmpty)
            _buildDetailItem(Icons.email, 'Email', widget.mechanic.email!),
          if (widget.mechanic.website != null &&
              widget.mechanic.website!.isNotEmpty)
            _buildDetailItem(Icons.public, 'Website', widget.mechanic.website!),
        ]),
        const SizedBox(height: 24),
        if (widget.mechanic.specialties.isNotEmpty)
          _buildDetailSection(
            'All Specialties',
            widget.mechanic.specialties
                .map(
                  (specialty) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppColors.successColor,
                        ),
                        const SizedBox(width: 8),
                        Text(specialty, style: AppStyles.bodyText1),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 32),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppStyles.headline3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppStyles.labelText.copyWith(
                    color: AppColors.secondaryTextColor,
                  ),
                ),
                Text(value, style: AppStyles.bodyText1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
