import 'package:flutter/material.dart';
import 'package:insuroo/theme/app_theme.dart';

class MicButton extends StatefulWidget {
  final bool isRecording;
  final bool isSpeaking;
  final bool isDisabled;
  final VoidCallback onTap;

  const MicButton({
    required this.isRecording,
    required this.isSpeaking,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  State<MicButton> createState() => MicButtonState();
}

class MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MicButton old) {
    super.didUpdateWidget(old);
    if (widget.isRecording || widget.isSpeaking) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color ringColor;
    List<Color> buttonGradient;
    IconData icon;
    String tooltip;

    if (widget.isRecording) {
      ringColor = const Color(0xFFFF5252);
      buttonGradient = const [Color(0xFFFF5252), Color(0xFFFF1744)];
      icon = Icons.mic_rounded;
      tooltip = 'Tap to stop recording';
    } else if (widget.isSpeaking) {
      ringColor = AppTheme.successColor;
      buttonGradient = [AppTheme.successColor, AppTheme.accentColor];
      icon = Icons.volume_up_rounded;
      tooltip = 'Speaking\u2026';
    } else {
      ringColor = Colors.transparent;
      buttonGradient = const [AppTheme.primaryColor, AppTheme.accentColor];
      icon = Icons.mic_none_rounded;
      tooltip = 'Tap to speak';
    }

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: widget.isDisabled ? null : widget.onTap,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing ring (only while active)
                if (widget.isRecording || widget.isSpeaking)
                  Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ringColor.withOpacity(0.6),
                          width: 2,
                        ),
                        color: ringColor.withOpacity(0.12),
                      ),
                    ),
                  ),
                // The button
                AnimatedOpacity(
                  opacity: widget.isDisabled ? 0.4 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: buttonGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: buttonGradient.first.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
