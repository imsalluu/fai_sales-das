import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  final String? subtitle;
  final Widget? subtitleIcon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
    this.subtitle,
    this.subtitleIcon,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: widget.gradientColors.first.withOpacity(_isHovered ? 0.4 : 0.25),
              blurRadius: _isHovered ? 40 : 32,
              offset: Offset(0, _isHovered ? 16 : 12),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 1,
              spreadRadius: -1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Gradient Background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Decorative Glow
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                top: _isHovered ? -10 : -20,
                right: _isHovered ? -10 : -20,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: _isHovered ? 140 : 100,
                  height: _isHovered ? 140 : 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(_isHovered ? 0.25 : 0.15),
                  ),
                ),
              ),
              // Glass Border Overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(_isHovered ? 0.35 : 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(widget.icon, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                    const Spacer(),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: _isHovered ? 36 : 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.5,
                      ),
                      child: Text(widget.value),
                    ),
                    const SizedBox(height: 8),
                    if (widget.subtitle != null)
                      Row(
                        children: [
                          if (widget.subtitleIcon != null) ...[
                            widget.subtitleIcon!,
                            const SizedBox(width: 6),
                          ],
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
