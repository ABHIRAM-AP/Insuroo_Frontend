import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import 'dart:math' as math;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _gradientController;
  bool _isFocused = false;

  final List<String> _suggestedQuestions = [
    'What does term life insurance cover?',
    'How do I file a health insurance claim?',
    'What is the difference between HMO and PPO?',
    'What factors affect car insurance premiums?',
    'What is a deductible in insurance?',
  ];

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatProvider>().sendMessage(text);
    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _gradientController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      math.cos(_gradientController.value * 2 * math.pi) * 0.5,
                      math.sin(_gradientController.value * 2 * math.pi) * 0.5,
                    ),
                    end: Alignment(
                      -math.cos(_gradientController.value * 2 * math.pi) * 0.5,
                      -math.sin(_gradientController.value * 2 * math.pi) * 0.5,
                    ),
                    colors: const [
                      Color(0xFF0F0F1A),
                      Color(0xFF12122A),
                      Color(0xFF0F1A1A),
                    ],
                  ),
                ),
              );
            },
          ),
          // Fixed glowing orbs
          Positioned(
            top: -80,
            right: -80,
            child: _buildGlowOrb(AppTheme.primaryColor.withOpacity(0.15), 240),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: _buildGlowOrb(AppTheme.accentColor.withOpacity(0.1), 200),
          ),
          // Main structure
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildMessageList()),
                _buildInputSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: size * 0.8)],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            children: [
              // Logo/Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                    child: Text('🛡️', style: TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Insuroo AI',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: provider.isServerOnline
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: provider.isServerOnline
                                    ? AppTheme.successColor.withOpacity(0.6)
                                    : AppTheme.errorColor.withOpacity(0.6),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            provider.isServerOnline
                                ? 'Online — Ready to help'
                                : 'Offline — Start the backend server',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Actions
              Row(
                children: [
                  IconButton(
                    onPressed: provider.retryHealthCheck,
                    icon: const Icon(Icons.wifi_tethering_rounded,
                        color: AppTheme.textSecondary, size: 20),
                    tooltip: 'Check connection',
                  ),
                  IconButton(
                    onPressed: provider.clearChat,
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppTheme.textSecondary, size: 20),
                    tooltip: 'Clear chat',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageList() {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        if (provider.messages.isEmpty) {
          return _buildEmptyState(provider);
        }
        _scrollToBottom();
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.messages.length) {
              return const TypingIndicator();
            }
            return ChatBubble(message: provider.messages[index]);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(ChatProvider provider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            // Welcome card
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark.withOpacity(0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.dividerColor.withOpacity(0.6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.08),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.accentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                        child: Text('🛡️', style: TextStyle(fontSize: 36))),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome to Insuroo AI',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your intelligent insurance assistant powered by RAG. Ask me anything about insurance policies, claims, and coverage.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Suggested Questions',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ..._suggestedQuestions.map(
              (q) => _SuggestedCard(
                question: q,
                onTap: () {
                  _controller.text = q;
                  _send();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.backgroundDark.withOpacity(0),
            AppTheme.backgroundDark,
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Mic button ──────────────────────────────────────────────────
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              return _MicButton(
                isRecording: provider.isRecording,
                isSpeaking: provider.isSpeaking,
                isDisabled: provider.isLoading,
                onTap: () {
                  if (provider.isRecording) {
                    provider.stopVoiceInput();
                  } else {
                    provider.startVoiceInput();
                  }
                },
              );
            },
          ),
          const SizedBox(width: 10),
          // ── Text field ──────────────────────────────────────────────────
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Focus(
                onFocusChange: (focused) =>
                    setState(() => _isFocused = focused),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Ask about insurance...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide:
                          BorderSide(color: AppTheme.primaryColor, width: 1.5),
                    ),
                    fillColor: AppTheme.cardDark,
                    filled: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                  maxLines: 4,
                  minLines: 1,
                  onSubmitted: (_) => _send(),
                  textInputAction: TextInputAction.newline,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              return AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 150),
                child: GestureDetector(
                  onTap: provider.isLoading ? null : _send,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: provider.isLoading
                          ? const LinearGradient(
                              colors: [AppTheme.cardDark, AppTheme.cardDark],
                            )
                          : const LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.accentColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: provider.isLoading
                          ? []
                          : [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Icon(
                      provider.isLoading
                          ? Icons.hourglass_empty_rounded
                          : Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SuggestedCard extends StatefulWidget {
  final String question;
  final VoidCallback onTap;

  const _SuggestedCard({required this.question, required this.onTap});

  @override
  State<_SuggestedCard> createState() => _SuggestedCardState();
}

class _SuggestedCardState extends State<_SuggestedCard> {
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

// ─── Mic Button ──────────────────────────────────────────────────────────────

class _MicButton extends StatefulWidget {
  final bool isRecording;
  final bool isSpeaking;
  final bool isDisabled;
  final VoidCallback onTap;

  const _MicButton({
    required this.isRecording,
    required this.isSpeaking,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  State<_MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<_MicButton>
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
  void didUpdateWidget(_MicButton old) {
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
