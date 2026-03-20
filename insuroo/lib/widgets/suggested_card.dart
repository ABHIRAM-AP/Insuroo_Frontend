import 'package:flutter/material.dart';
import 'package:insuroo/theme/app_theme.dart';

class SuggestedCard extends StatefulWidget {
  final String question;
  final VoidCallback onTap;

  const SuggestedCard({required this.question, required this.onTap});

  @override
  State<SuggestedCard> createState() => SuggestedCardState();
}

class SuggestedCardState extends State<SuggestedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered
                ? AppTheme.primaryColor.withOpacity(0.15)
                : AppTheme.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? AppTheme.primaryColor.withOpacity(0.6)
                  : AppTheme.dividerColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: AppTheme.primaryColor, size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.question,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppTheme.textSecondary, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
