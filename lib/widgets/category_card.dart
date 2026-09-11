import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Accordion-Karte im Stil der UKSH-Beatmungsleitlinie-App:
/// links Icon-Kachel, Mitte Titel+Untertitel, rechts Chevron.
class CategoryCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final bool initiallyExpanded;
  final Color? iconColor;
  final Color? iconBgColor;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.initiallyExpanded = false,
    this.iconColor,
    this.iconBgColor,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.iconBgColor ?? AppColors.chipBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor ?? AppColors.primaryBlue, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryBlue, fontSize: 15.5)),
                        const SizedBox(height: 2),
                        Text(widget.subtitle,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: widget.child,
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}
