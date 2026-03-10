import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/core/services/voice_service.dart';
import 'package:farmconnect/core/services/voice_command_handler.dart';
import 'package:farmconnect/core/services/voice_language_provider.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class VoiceButton extends ConsumerStatefulWidget {
  const VoiceButton({super.key});

  @override
  ConsumerState<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends ConsumerState<VoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _initialized = false;
  bool _isInitializing = false;
  VoiceLanguage _currentLanguage = supportedVoiceLanguages.first;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initService();
    });
  }

  Future<void> _initService() async {
    if (_initialized || _isInitializing) return;
    _isInitializing = true;
    
    debugPrint('Initializing voice service...');
    final voiceService = ref.read(voiceServiceProvider.notifier);
    final handler = ref.read(voiceCommandHandlerProvider);
    
    voiceService.setCommandHandler((cmd) {
      debugPrint('Command received: $cmd');
      handler.handleCommand(cmd, languageCode: _currentLanguage.code);
    });
    
    final success = await voiceService.initialize();
    debugPrint('Voice service initialized: $success');
    _initialized = true;
    _isInitializing = false;
    
    if (success) {
      await voiceService.speak('Voice assistant ready');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    final voiceService = ref.read(voiceServiceProvider.notifier);
    final currentState = ref.read(voiceServiceProvider).state;
    
    debugPrint('Current voice state: $currentState');
    
    if (currentState == VoiceState.listening) {
      _controller.stop();
      _controller.reset();
      await voiceService.stopListening();
    } else if (currentState == VoiceState.idle || currentState == VoiceState.error) {
      _controller.repeat(reverse: true);
      await voiceService.startListening();
    } else if (currentState == VoiceState.speaking) {
      await voiceService.stopSpeaking();
      _controller.repeat(reverse: true);
      await voiceService.startListening();
    }
  }

  void _showLanguageSelector() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(DesignRadius.xxl)),
        ),
        padding: const EdgeInsets.all(DesignSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DesignColors.secondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DesignSpacing.m),
            Text(
              'Select Voice Language',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: DesignColors.textPrimary,
              ),
            ),
            const SizedBox(height: DesignSpacing.s),
            Text(
              'Choose your preferred language for voice commands',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: DesignColors.textSecondary,
              ),
            ),
            const SizedBox(height: DesignSpacing.l),
            ...supportedVoiceLanguages.map((lang) => _buildLanguageOption(lang)),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(VoiceLanguage lang) {
    final isSelected = _currentLanguage.code == lang.code;
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        setState(() {
          _currentLanguage = lang;
        });
        
        final voiceService = ref.read(voiceServiceProvider.notifier);
        await voiceService.setLanguage(lang);
        
        if (mounted) {
          Navigator.pop(context);
          await voiceService.speak('Language set to ${lang.name}');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? DesignColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(DesignRadius.l),
          border: Border.all(
            color: isSelected ? DesignColors.primary : DesignColors.secondary,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? DesignColors.primary : DesignColors.surfaceVariant,
                borderRadius: BorderRadius.circular(DesignRadius.m),
              ),
              child: Center(
                child: Text(
                  _getLanguageEmoji(lang.code),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.name,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? DesignColors.primary : DesignColors.textPrimary,
                    ),
                  ),
                  Text(
                    lang.nativeName,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: DesignColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: DesignColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  String _getLanguageEmoji(String code) {
    switch (code) {
      case 'en':
        return '🇬🇧';
      case 'ta':
        return '🇮🇳';
      case 'hi':
        return '🇮🇳';
      case 'te':
        return '🇮🇳';
      case 'kn':
        return '🇮🇳';
      case 'ml':
        return '🇮🇳';
      case 'th':
        return '🌐';
      default:
        return '🌐';
    }
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceServiceProvider);
    final isListening = voiceState.state == VoiceState.listening;

    ref.listen<VoiceServiceState>(voiceServiceProvider, (prev, next) {
      debugPrint('Voice state changed: ${prev?.state} -> ${next.state}');
      
      if (next.state == VoiceState.idle && _controller.isAnimating) {
        _controller.stop();
        _controller.reset();
      }
      
      if (next.state == VoiceState.speaking && prev?.state != VoiceState.speaking) {
        debugPrint('Speaking: ${next.lastResult}');
      }
    });

    return GestureDetector(
      onLongPress: _showLanguageSelector,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isListening ? _scaleAnimation.value : 1.0,
            child: child,
          );
        },
        child: GestureDetector(
          onTap: _toggleListening,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF28D339), Color(0xFF1BAF26)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF28D339).withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                  spreadRadius: 1,
                ),
              ],
              border: isListening
                  ? Border.all(
                      color: Colors.red,
                      width: 3,
                    )
                  : Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                if (isListening)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

