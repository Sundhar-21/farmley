import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String ttsCode;
  final String sttCode;

  const VoiceLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.ttsCode,
    required this.sttCode,
  });
}

const supportedVoiceLanguages = [
  VoiceLanguage(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    ttsCode: 'en-US',
    sttCode: 'en_US',
  ),
  VoiceLanguage(
    code: 'ta',
    name: 'Tamil',
    nativeName: 'தமிழ்',
    ttsCode: 'ta-IN',
    sttCode: 'ta_IN',
  ),
  VoiceLanguage(
    code: 'hi',
    name: 'Hindi',
    nativeName: 'हिन्दी',
    ttsCode: 'hi-IN',
    sttCode: 'hi_IN',
  ),
  VoiceLanguage(
    code: 'te',
    name: 'Telugu',
    nativeName: 'తెలుగు',
    ttsCode: 'te-IN',
    sttCode: 'te_IN',
  ),
  VoiceLanguage(
    code: 'kn',
    name: 'Kannada',
    nativeName: 'ಕನ್ನಡ',
    ttsCode: 'kn-IN',
    sttCode: 'kn_IN',
  ),
  VoiceLanguage(
    code: 'ml',
    name: 'Malayalam',
    nativeName: 'മലയാളം',
    ttsCode: 'ml-IN',
    sttCode: 'ml_IN',
  ),
  VoiceLanguage(
    code: 'th',
    name: 'Thunglish',
    nativeName: 'Thunglish',
    ttsCode: 'en-US',
    sttCode: 'en_US',
  ),
];

final voiceLanguageProvider = StateProvider<VoiceLanguage>((ref) {
  return supportedVoiceLanguages.first;
});
