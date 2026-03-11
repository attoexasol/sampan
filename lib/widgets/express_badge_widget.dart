import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';

/// Reusable Express Delivery badge widget with lightning icon.
/// Shows a consistent express indicator across the app.
class ExpressBadge extends StatelessWidget {
  final ExpressBadgeSize size;
  final bool showLabel;
  final String? customLabel;
  final bool animate;

  const ExpressBadge({
    super.key,
    this.size = ExpressBadgeSize.medium,
    this.showLabel = true,
    this.customLabel,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: config.paddingH,
        vertical: config.paddingV,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(config.borderRadius),
        border: Border.all(color: Colors.orange.shade300, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(config),
          if (showLabel) ...[
            SizedBox(width: config.spacing),
            Text(
              customLabel ?? 'Express',
              style: TextStyle(
                fontSize: config.fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(_BadgeConfig config) {
    final icon = Icon(
      Icons.bolt,
      size: config.iconSize,
      color: Colors.orange.shade700,
    );
    
    if (animate) {
      return _AnimatedBolt(size: config.iconSize);
    }
    
    return icon;
  }

  _BadgeConfig _getConfig() {
    switch (size) {
      case ExpressBadgeSize.small:
        return _BadgeConfig(
          iconSize: 12,
          fontSize: AppSizes.fontXs,
          paddingH: 6,
          paddingV: 2,
          spacing: 2,
          borderRadius: 4,
        );
      case ExpressBadgeSize.medium:
        return _BadgeConfig(
          iconSize: 16,
          fontSize: AppSizes.fontSm,
          paddingH: 8,
          paddingV: 4,
          spacing: 4,
          borderRadius: 6,
        );
      case ExpressBadgeSize.large:
        return _BadgeConfig(
          iconSize: 20,
          fontSize: AppSizes.fontMd,
          paddingH: 12,
          paddingV: 6,
          spacing: 6,
          borderRadius: 8,
        );
    }
  }
}

/// Express icon only (no background/border)
class ExpressIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const ExpressIcon({
    super.key,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.bolt,
      size: size,
      color: color ?? Colors.orange.shade700,
    );
  }
}

/// Express delivery banner with full details
class ExpressBanner extends StatelessWidget {
  final String? turnaroundText;
  final String? feeText;
  final double? expressFee;

  const ExpressBanner({
    super.key,
    this.turnaroundText,
    this.feeText,
    this.expressFee,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade50,
            Colors.amber.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bolt,
              color: Colors.orange.shade700,
              size: 24,
            ),
          ),
          SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '⚡ Express Delivery',
                      style: TextStyle(
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                if (turnaroundText != null || feeText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    turnaroundText ?? feeText ?? '5% express fee applies',
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      color: Colors.orange.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (expressFee != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '+\$${expressFee!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Animated bolt icon with pulse effect
class _AnimatedBolt extends StatefulWidget {
  final double size;

  const _AnimatedBolt({required this.size});

  @override
  State<_AnimatedBolt> createState() => _AnimatedBoltState();
}

class _AnimatedBoltState extends State<_AnimatedBolt>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Icon(
            Icons.bolt,
            size: widget.size,
            color: Colors.orange.shade700,
          ),
        );
      },
    );
  }
}

enum ExpressBadgeSize { small, medium, large }

class _BadgeConfig {
  final double iconSize;
  final double fontSize;
  final double paddingH;
  final double paddingV;
  final double spacing;
  final double borderRadius;

  _BadgeConfig({
    required this.iconSize,
    required this.fontSize,
    required this.paddingH,
    required this.paddingV,
    required this.spacing,
    required this.borderRadius,
  });
}
