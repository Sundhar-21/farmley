import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/core/services/voice_service.dart';
import 'package:farmconnect/features/consumer/data/navigation_provider.dart';
import 'package:farmconnect/features/consumer/data/product_provider.dart';
import 'package:farmconnect/features/consumer/data/cart_provider.dart';
import 'package:farmconnect/features/consumer/data/search_provider.dart';

class VoiceCommandHandler {
  final Ref ref;
  final VoiceService voiceService;
  String _currentLanguage = 'en';

  VoiceCommandHandler(this.ref, this.voiceService);

  void setLanguage(String langCode) {
    _currentLanguage = langCode;
  }

  Future<void> handleCommand(String command, {String languageCode = 'en'}) async {
    _currentLanguage = languageCode;
    final lowerCommand = command.toLowerCase().trim();
    
    if (lowerCommand.isEmpty) {
      await _speakNotHeard();
      return;
    }

    switch (languageCode) {
      case 'ta':
        await _handleTamilCommand(lowerCommand);
        break;
      case 'hi':
        await _handleHindiCommand(lowerCommand);
        break;
      case 'te':
        await _handleTeluguCommand(lowerCommand);
        break;
      case 'kn':
        await _handleKannadaCommand(lowerCommand);
        break;
      case 'ml':
        await _handleMalayalamCommand(lowerCommand);
        break;
      case 'th':
        await _handleThunglishCommand(lowerCommand);
        break;
      default:
        await _handleEnglishCommand(lowerCommand);
    }
  }

  Future<void> _speakNotHeard() async {
    switch (_currentLanguage) {
      case 'ta':
        await voiceService.speak('எனக்கு கேட்கவில்லை. மீண்டும் முயற்சிக்கவும்.');
        break;
      case 'hi':
        await voiceService.speak('मुझे सुनाई नहीं दिया। कृपया पुनः प्रयास करें।');
        break;
      case 'te':
        await voiceService.speak('నాకు వినిపించలేదు. దయచేసి మళ్ళీ ప్రయత్నించండి.');
        break;
      case 'kn':
        await voiceService.speak('ನನಗೆ ಕೇಳುತ್ತಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.');
        break;
      case 'ml':
        await voiceService.speak('എനിക്ക് കേട്ടില്ല. വീണ്ടും ശ്രമിക്കുക.');
        break;
      default:
        await voiceService.speak('I did not hear anything. Please try again.');
    }
  }

  Future<void> _handleEnglishCommand(String command) async {
    if (_matchCommand(command, ['go to home', 'open home', 'show home', 'home page', 'home', 'go home'])) {
      ref.read(navigationIndexProvider.notifier).state = 0;
      await voiceService.speak('Opening home');
      return;
    }

    if (_matchCommand(command, ['go to search', 'open search', 'search page', 'find', 'go to markets', 'markets', 'go to market', 'open market'])) {
      ref.read(navigationIndexProvider.notifier).state = 1;
      await voiceService.speak('Opening search');
      return;
    }

    if (_matchCommand(command, ['go to favorites', 'open favorites', 'my favorites', 'favourites', 'favorites'])) {
      ref.read(navigationIndexProvider.notifier).state = 2;
      await voiceService.speak('Opening favorites');
      return;
    }

    if (_matchCommand(command, ['go to cart', 'open cart', 'my cart', 'shopping cart', 'basket', 'cart page'])) {
      ref.read(navigationIndexProvider.notifier).state = 3;
      await voiceService.speak('Opening cart');
      return;
    }

    if (_matchCommand(command, ['go to profile', 'open profile', 'my account', 'account page', 'profile page'])) {
      ref.read(navigationIndexProvider.notifier).state = 4;
      await voiceService.speak('Opening profile');
      return;
    }

    if (_matchCommand(command, ['search for', 'find', 'look for', 'show me', 'search', 'search product', 'find product'])) {
      final searchTerm = _extractSearchTerm(command);
      if (searchTerm.isNotEmpty) {
        await _performSearch(searchTerm);
        return;
      }
      ref.read(navigationIndexProvider.notifier).state = 1;
      await voiceService.speak('Opening search. What would you like to find?');
      return;
    }

    if (_matchCommand(command, ['add to cart', 'buy', 'purchase', 'add', 'add to basket'])) {
      final productName = _extractProductName(command);
      if (productName.isNotEmpty) {
        await _addProductToCart(productName);
        return;
      }
      await voiceService.speak('Which product would you like to add?');
      return;
    }

    if (_matchCommand(command, ['clear cart', 'empty cart', 'remove all', 'delete cart', 'clear basket'])) {
      ref.read(cartProvider.notifier).clearCart();
      await voiceService.speak('Cart cleared');
      return;
    }

    if (_matchCommand(command, ['total', 'price', 'cost', 'bill', 'amount', 'how much', 'check total', 'total amount'])) {
      final cart = ref.read(cartProvider);
      final total = cart.fold(0.0, (sum, item) => sum + (item.product['price'] * item.quantity));
      await voiceService.speak('Your total is ${total.toStringAsFixed(0)} rupees');
      return;
    }

    if (_matchCommand(command, ['items in cart', 'cart items', 'number of items', 'how many items', 'item count'])) {
      final cart = ref.read(cartProvider);
      final count = cart.fold(0, (sum, item) => sum + item.quantity);
      await voiceService.speak('You have $count items in cart');
      return;
    }

    if (_matchCommand(command, ['help', 'commands', 'what can you do', 'help me', 'assist', 'list commands'])) {
      await voiceService.speak('Say home to go to home. Say search to find products. Say favorites to see your favorites. Say cart to view your cart. Say profile to open your profile. Say search followed by product name to find products.');
      return;
    }

    await _handleUnknownCommand();
  }

  Future<void> _handleTamilCommand(String command) async {
    if (_matchCommand(command, ['வீடு', 'முகப்பு', 'home page', 'go to home'])) {
      ref.read(navigationIndexProvider.notifier).state = 0;
      await voiceService.speak('முகப்பு பக்கம் திறக்கிறேன்');
      return;
    }

    if (_matchCommand(command, ['தேடல்', 'search', 'find', 'சந்தை', 'market'])) {
      ref.read(navigationIndexProvider.notifier).state = 1;
      await voiceService.speak('தேடல் பக்கம் திறக்கிறேன்');
      return;
    }

    if (_matchCommand(command, ['பிடித்தவை', 'favorites', 'favourites', 'முத்துக்கள்'])) {
      ref.read(navigationIndexProvider.notifier).state = 2;
      await voiceService.speak('பிடித்தவை பக்கம் திறக்கிறேன்');
      return;
    }

    if (_matchCommand(command, ['கார்ட்', 'cart', 'பை', 'basket', 'ஷாப்பிங்'])) {
      ref.read(navigationIndexProvider.notifier).state = 3;
      await voiceService.speak('கார்ட் திறக்கிறேன்');
      return;
    }

    if (_matchCommand(command, ['profil', 'profile', 'account', 'கணக்கு'])) {
      ref.read(navigationIndexProvider.notifier).state = 4;
      await voiceService.speak('புரோபைல் திறக்கிறேன்');
      return;
    }

    if (_matchCommand(command, ['தேடு', 'search for', 'find', 'கிடைக்கிறதா', 'வாங்க'])) {
      final searchTerm = _extractSearchTermTamil(command);
      if (searchTerm.isNotEmpty) {
        await _performSearch(searchTerm);
        return;
      }
      ref.read(navigationIndexProvider.notifier).state = 1;
      await voiceService.speak('தேடல் பக்கம் திறக்கிறேன்.எதை தேட விரும்புகிறீர்கள்?');
      return;
    }

    if (_matchCommand(command, ['கார்ட்டில் சேர்', 'add to cart', 'buy', 'வாங்க', 'சேர்'])) {
      final productName = _extractProductNameTamil(command);
      if (productName.isNotEmpty) {
        await _addProductToCart(productName);
        return;
      }
      await voiceService.speak('எந்த பொருளை சேர்க்க விரும்புகிறீர்கள்?');
      return;
    }

    if (_matchCommand(command, ['கார்ட் அழி', 'clear cart', 'அழி', 'நீக்கு'])) {
      ref.read(cartProvider.notifier).clearCart();
      await voiceService.speak('கார்ட் அழிக்கப்பட்டது');
      return;
    }

    if (_matchCommand(command, ['மொத்தம்', 'total', 'விலை', 'price', 'தொகை'])) {
      final cart = ref.read(cartProvider);
      final total = cart.fold(0.0, (sum, item) => sum + (item.product['price'] * item.quantity));
      await voiceService.speak('உங்கள் மொத்தம் ${total.toStringAsFixed(0)} ரூபாய்');
      return;
    }

    if (_matchCommand(command, ['எத்தனை', 'items', 'number of', 'கணக்கு'])) {
      final cart = ref.read(cartProvider);
      final count = cart.fold(0, (sum, item) => sum + item.quantity);
      await voiceService.speak('உங்களிடம் $count பொருட்கள் உள்ளன');
      return;
    }

    if (_matchCommand(command, ['help', 'உதவி', 'commands', 'என்ன செய்ய முடியும்'])) {
      await voiceService.speak('வீடு என்றால் முகப்பு பக்கம். தேடு என்றால் தேடல். கார்ட் என்றால் கார்ட். புரோபைல் என்றால் கணக்கு. தேடு + பொருள் பெயர் என்றால் தேடும்.');
      return;
    }

    await _handleUnknownCommand();
  }

  Future<void> _handleHindiCommand(String command) async {
    if (_matchCommand(command, ['घर', 'home', 'होम', 'मुख्य पृष्ठ'])) {
      ref.read(navigationIndexProvider.notifier).state = 0;
      await voiceService.speak('होम खोल रहा हूं');
      return;
    }

    if (_matchCommand(command, ['खोज', 'search', 'find', 'बाजार', 'market'])) {
      ref.read(navigationIndexProvider.notifier).state = 1;
      await voiceService.speak('खोज खोल रहा हूं');
      return;
    }

    if (_matchCommand(command, ['पसंदीदा', 'favorites', 'favourites'])) {
      ref.read(navigationIndexProvider.notifier).state = 2;
      await voiceService.speak('पसंदीदा खोल रहा हूं');
      return;
    }

    if (_matchCommand(command, ['कार्ट', 'cart', 'बास्केट', 'basket'])) {
      ref.read(navigationIndexProvider.notifier).state = 3;
      await voiceService.speak('कार्ट खोल रहा हूं');
      return;
    }

    if (_matchCommand(command, ['प्रोफ़ाइल', 'profile', 'account', 'खाता'])) {
      ref.read(navigationIndexProvider.notifier).state = 4;
      await voiceService.speak('प्रोफ़ाइल खोल रहा हूं');
      return;
    }

    if (_matchCommand(command, ['खोजो', 'search for', 'find', 'दिखाओ'])) {
      final searchTerm = _extractSearchTermHindi(command);
      if (searchTerm.isNotEmpty) {
        await _performSearch(searchTerm);
        return;
      }
      ref.read(navigationIndexProvider.notifier).state = 1;
      await voiceService.speak('खोज खोल रहा हूं। आप क्या खोजना चाहते हैं?');
      return;
    }

    if (_matchCommand(command, ['कार्ट में डालो', 'add to cart', 'खरीदो', 'खरीद'])) {
      final productName = _extractProductNameHindi(command);
      if (productName.isNotEmpty) {
        await _addProductToCart(productName);
        return;
      }
      await voiceService.speak('आप कौन सा उत्पाद जोड़ना चाहते हैं?');
      return;
    }

    if (_matchCommand(command, ['कार्ट साफ़ करो', 'clear cart', 'हटाओ'])) {
      ref.read(cartProvider.notifier).clearCart();
      await voiceService.speak('कार्ट साफ़ हो गया');
      return;
    }

    if (_matchCommand(command, ['कुल', 'total', 'कीमत', 'price', 'भुगतान'])) {
      final cart = ref.read(cartProvider);
      final total = cart.fold(0.0, (sum, item) => sum + (item.product['price'] * item.quantity));
      await voiceService.speak('आपका कुल ${total.toStringAsFixed(0)} रुपये है');
      return;
    }

    if (_matchCommand(command, ['कितने', 'items', 'number of'])) {
      final cart = ref.read(cartProvider);
      final count = cart.fold(0, (sum, item) => sum + item.quantity);
      await voiceService.speak('आपके पास $count आइटम हैं');
      return;
    }

    if (_matchCommand(command, ['help', 'मदद', 'क्या कर सकते हो'])) {
      await voiceService.speak('घर के लिए घर बोलो। खोज के लिए खोज बोलो। कार्ट के लिए कार्ट बोलो। प्रोफ़ाइल के लिए प्रोफ़ाइल बोलो।');
      return;
    }

    await _handleUnknownCommand();
  }

  Future<void> _handleTeluguCommand(String command) async {
    if (_matchCommand(command, ['home', 'hous', 'velu', 'తల'])) {
      ref.read(navigationIndexProvider.notifier).state = 0;
      await voiceService.speak('హోం తెరుస్తున్నా');
      return;
    }

    if (_matchCommand(command, ['search', 'find', 'telesu', 'తెలుసు'])) {
      ref.read(navigationIndexProvider.notifier).state = 1;
      await voiceService.speak('శోధన తెరుస్తున్నా');
      return;
    }

    if (_matchCommand(command, ['cart', 'basket', 'patti', 'पत्ति'])) {
      ref.read(navigationIndexProvider.notifier).state = 3;
      await voiceService.speak('కార్ట్ తెరుస్తున్నా');
      return;
    }

    if (_matchCommand(command, ['profile', 'account', 'vivaram', 'विव�'])) {
      ref.read(navigationIndexProvider.notifier).state = 4;
      await voiceService.speak('ప్రొఫైల్ తెరుస్తున్నా');
      return;
    }

    await _handleUnknownCommand();
  }

  Future<void> _handleKannadaCommand(String command) async {
    if (_matchCommand(command, ['home', 'mane', 'ಮನೆ'])) {
      ref.read(navigationIndexProvider.notifier).state = 0;
      await voiceService.speak('ಹೋಮ್ ತೆರೆಯುತ್ತಿದ್ದೇನೆ');
      return;
    }

    if (_matchCommand(command, ['search', 'sisu', 'ಸೆಸು'])) {
      ref.read(navigationIndexProvider.notifier).state = 1;
      await voiceService.speak('ಸರ್ಚ್ ತೆರೆಯುತ್ತಿದ್ದೇನೆ');
      return;
    }

    if (_matchCommand(command, ['cart', 'basket', 'guttu', 'ಗುಟ್ಟು'])) {
      ref.read(navigationIndexProvider.notifier).state = 3;
      await voiceService.speak('ಕಾರ್ಟ್ ತೆರೆಯುತ್ತಿದ್ದೇನೆ');
      return;
    }

    if (_matchCommand(command, ['profile', 'account', 'shanivaar', 'ಶನಿವಾರ'])) {
      ref.read(navigationIndexProvider.notifier).state = 4;
      await voiceService.speak('ಪ್ರೊಫೈಲ್ ತೆರೆಯುತ್ತಿದ್ದೇನೆ');
      return;
    }

    await _handleUnknownCommand();
  }

  Future<void> _handleMalayalamCommand(String command) async {
    if (_matchCommand(command, ['home', 'veedu', 'വീട്'])) {
      ref.read(navigationIndexProvider.notifier).state = 0;
      await voiceService.speak('ഹോം തുറക്കുന്നു');
      return;
    }

    if (_matchCommand(command, ['search', 'find', 'search', 'തിരയുക'])) {
      ref.read(navigationIndexProvider.notifier).state = 1;
      await voiceService.speak('സര്ച്ച് തുറക്കുന്നു');
      return;
    }

    if (_matchCommand(command, ['cart', 'basket', 'karthy', 'കാര്ട്ട്'])) {
      ref.read(navigationIndexProvider.notifier).state = 3;
      await voiceService.speak('കാര്ട്ട് തുറക്കുന്നു');
      return;
    }

    if (_matchCommand(command, ['profile', 'account', 'vivaram', 'വിവരം'])) {
      ref.read(navigationIndexProvider.notifier).state = 4;
      await voiceService.speak('പ്രൊഫൈല് തുറക്കുന്നു');
      return;
    }

    await _handleUnknownCommand();
  }

  Future<void> _handleThunglishCommand(String command) async {
    final processed = _processThunglish(command);
    await _handleEnglishCommand(processed);
  }

  String _processThunglish(String command) {
    final thunglishMap = {
      'home': 'home',
      'cart': 'cart',
      'search': 'search',
      'favorites': 'favorites',
      'profile': 'profile',
      'add to cart': 'add to cart',
      'clear cart': 'clear cart',
      'total': 'total',
      'vangi': 'brinjal',
      'thakkali': 'tomato',
      'pyaaz': 'onion',
      'aloo': 'potato',
      'carrot': 'carrot',
      'beans': 'beans',
    };

    String result = command;
    for (final entry in thunglishMap.entries) {
      if (result.contains(entry.key)) {
        result = result.replaceAll(entry.key, entry.value);
      }
    }
    return result;
  }

  Future<void> _handleUnknownCommand() async {
    switch (_currentLanguage) {
      case 'ta':
        await voiceService.speak('மன்னிக்கவும்ம, புரியவில்லை. உதவி கேட்கவும்.');
        break;
      case 'hi':
        await voiceService.speak('माफ़ कीजिए, समझ नहीं आया। मदद के लिए मदद बोलें।');
        break;
      default:
        await voiceService.speak('Sorry, I did not understand. Say help for available commands.');
    }
  }

  bool _matchCommand(String command, List<String> patterns) {
    return patterns.any((pattern) => command.contains(pattern));
  }

  String _extractSearchTerm(String command) {
    final patterns = ['search for ', 'find ', 'look for ', 'show me ', 'search ', 'search product ', 'find product '];
    for (final pattern in patterns) {
      if (command.contains(pattern)) {
        return command.split(pattern).last.trim();
      }
    }
    return command.trim();
  }

  String _extractSearchTermTamil(String command) {
    final patterns = ['தேடு ', 'தேடல் ', 'கிடைக்கிறதா ', 'வாங்க ', 'search '];
    for (final pattern in patterns) {
      if (command.contains(pattern)) {
        return command.split(pattern).last.trim();
      }
    }
    return command.trim();
  }

  String _extractSearchTermHindi(String command) {
    final patterns = ['खोजो ', 'खोज ', 'दिखाओ ', 'find ', 'search '];
    for (final pattern in patterns) {
      if (command.contains(pattern)) {
        return command.split(pattern).last.trim();
      }
    }
    return command.trim();
  }

  String _extractProductName(String command) {
    final patterns = ['add to cart ', 'buy ', 'purchase ', 'add ', 'add to basket '];
    for (final pattern in patterns) {
      if (command.contains(pattern)) {
        return command.split(pattern).last.trim();
      }
    }
    return command.replaceAll(RegExp(r'\d+'), '').trim();
  }

  String _extractProductNameTamil(String command) {
    final patterns = ['கார்ட்டில் சேர் ', 'சேர் ', 'வாங்க ', 'add '];
    for (final pattern in patterns) {
      if (command.contains(pattern)) {
        return command.split(pattern).last.trim();
      }
    }
    return command.trim();
  }

  String _extractProductNameHindi(String command) {
    final patterns = ['कार्ट में डालो ', 'खरीदो ', 'खरीद ', 'add '];
    for (final pattern in patterns) {
      if (command.contains(pattern)) {
        return command.split(pattern).last.trim();
      }
    }
    return command.trim();
  }

  Future<void> _performSearch(String searchTerm) async {
    ref.read(navigationIndexProvider.notifier).state = 1;
    ref.read(searchQueryProvider.notifier).state = searchTerm;
    
    final productsAsync = ref.read(productsProvider);
    productsAsync.whenData((products) {
      final matchingProducts = products.where((p) {
        final name = (p['name'] as String).toLowerCase();
        return name.contains(searchTerm.toLowerCase());
      }).toList();

      if (matchingProducts.isNotEmpty) {
        if (_currentLanguage == 'ta') {
          voiceService.speak('${matchingProducts.length} பொருட்கள் கிடைத்தன. ${matchingProducts.first['name']} உள்ளடக்கிய');
        } else if (_currentLanguage == 'hi') {
          voiceService.speak('${matchingProducts.length} उत्पाद मिले। ${matchingProducts.first['name']} सहित');
        } else {
          voiceService.speak('Found ${matchingProducts.length} products. Showing $searchTerm');
        }
      } else {
        if (_currentLanguage == 'ta') {
          voiceService.speak('$searchTermக்கு பொருட்கள் கிடைக்கவில்லை');
        } else if (_currentLanguage == 'hi') {
          voiceService.speak('$searchTerm के लिए कोई उत्पाद नहीं मिला');
        } else {
          voiceService.speak('No products found for $searchTerm');
        }
      }
    });
  }

  Future<void> _addProductToCart(String productName) async {
    final productsAsync = ref.read(productsProvider);
    productsAsync.whenData((products) {
      final matchingProducts = products.where((p) {
        final name = (p['name'] as String).toLowerCase();
        return name.contains(productName.toLowerCase());
      }).toList();

      if (matchingProducts.isNotEmpty) {
        final product = matchingProducts.first;
        ref.read(cartProvider.notifier).addToCart(product, product['unit'] ?? '500g', 1);
        
        if (_currentLanguage == 'ta') {
          voiceService.speak('${product['name']} கார்ட்டில் சேர்க்கப்பட்டது');
        } else if (_currentLanguage == 'hi') {
          voiceService.speak('${product['name']} कार्ट में जोड़ा गया');
        } else {
          voiceService.speak('Added ${product['name']} to cart');
        }
      } else {
        if (_currentLanguage == 'ta') {
          voiceService.speak('$productName கிடைக்கவில்லை');
        } else if (_currentLanguage == 'hi') {
          voiceService.speak('$productName नहीं मिला');
        } else {
          voiceService.speak('Product $productName not found');
        }
      }
    });
  }
}

final voiceCommandHandlerProvider = Provider<VoiceCommandHandler>((ref) {
  final voiceService = ref.watch(voiceServiceProvider.notifier);
  return VoiceCommandHandler(ref, voiceService);
});
